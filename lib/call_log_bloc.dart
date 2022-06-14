import 'package:call_log/call_log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_in_whatsapp/app_launcher.dart' as app_launcher;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CallLogCubitState {
  final List<CallLogEntry> callLogs;
  const CallLogCubitState({required this.callLogs});
}

class CallLogLoadingCubitState extends CallLogCubitState {
  const CallLogLoadingCubitState() : super(callLogs: const []);
}

class CallLogPermissionState extends CallLogCubitState {
  const CallLogPermissionState() : super(callLogs: const []);
}

class CallLogCountryCodeState extends CallLogCubitState {
  const CallLogCountryCodeState() : super(callLogs: const []);
}

class CallLogCubit extends Cubit<CallLogCubitState> {
  static const String countryCodeKey = "countryCode";
  final SharedPreferences pref;
  String _countryCode = "";
  CallLogCubit(this.pref) : super(const CallLogLoadingCubitState()) {
    _countryCode = pref.getString(countryCodeKey) ?? "";
    _initialize();
  }
  void refreshPermission() => _initialize();

  void _initialize() async {
    if (_countryCode.isEmpty) return emit(const CallLogCountryCodeState());
    Permission.phone.isGranted.then(
      (value) async {
        if (!value) return emit(const CallLogPermissionState());
        fetchLogs();
      },
    );
  }

  void requestPermission() async {
    PermissionStatus status = await Permission.phone.request();
    if (status.isGranted) fetchLogs();
  }

  void fetchLogs() async {
    DateTime now = DateTime.now();
    int from = now.subtract(const Duration(days: 2)).millisecondsSinceEpoch;
    int to = now.add(const Duration(hours: 1)).millisecondsSinceEpoch;
    Iterable<CallLogEntry> entries = await CallLog.query(
      dateFrom: from,
      dateTo: to,
    );
    emit(CallLogCubitState(callLogs: entries.toList()));
  }

  void setCountryCode(String? code) async {
    if (code == null) return;
    if (code.isEmpty) return;
    bool didSave = await pref.setString(countryCodeKey, code);
    if (!didSave) emit(const CallLogCountryCodeState());
    _countryCode = code;
    _initialize();
  }

  void openInWhatsapp(String number) {
    number = _sanitizePhoneNumber(number);
    app_launcher.openInWhatsapp(number: number);
  }

  void openInTelegram(String number) {
    number = _sanitizePhoneNumber(number);
    app_launcher.openInTelegram(number: number);
  }

  void openInSms(String number) {
    number = _sanitizePhoneNumber(number);
    app_launcher.openInSms(number: number);
  }

  String _sanitizePhoneNumber(String number) {
    if (number.length < 2) return number;
    bool startsWithCode = number[0] == "+";
    if (startsWithCode) return number;
    bool startsWithZero = number[0] == "0" && number[1] == "0";
    if (startsWithZero) {
      number = number.replaceFirst("00", "+");
      return number;
    }
    number = "$_countryCode$number";
    return number;
  }

  bool isSetUp() =>
      state is CallLogCountryCodeState || state is CallLogPermissionState;
}
