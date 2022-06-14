import 'package:call_log/call_log.dart';
import 'package:country_codes/country_codes.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:open_in_whatsapp/call_log_bloc.dart';
import 'package:open_in_whatsapp/change_code_screen.dart';
import 'package:open_in_whatsapp/dialpad_screen.dart';
import 'package:open_in_whatsapp/router_util.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  late final CallLogCubit _cubit;
  @override
  void initState() {
    _cubit = BlocProvider.of<CallLogCubit>(context);
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (AppLifecycleState.resumed == state) _cubit.refreshPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: const AppBarTitle(),
          actions: const [AppBarSettingsButton()],
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: UniqueKey(),
          onPressed: () {
            Navigator.of(context).push(createRoute(
              context,
              BlocProvider.value(
                value: _cubit,
                child: const DialPadScreen(),
              ),
            ));
          },
          child: const Icon(Icons.dialpad_outlined),
        ),
        body: BlocBuilder<CallLogCubit, CallLogCubitState>(
          builder: (context, state) {
            bool isPermissionRequired = state is CallLogPermissionState;
            bool isSelectCountryCode = state is CallLogCountryCodeState;
            if (isSelectCountryCode) {
              return SelectCountryCodeWidget(onTap: _cubit.setCountryCode);
            }
            if (isPermissionRequired) return const PermissionRequiredWidget();
            return CallEntryList(
              cubit: _cubit,
              callLogs: state.callLogs,
            );
          },
        ));
  }
}

class AppBarTitle extends StatelessWidget {
  const AppBarTitle({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CallLogCubit, CallLogCubitState>(
      builder: (context, state) {
        bool isSetup = BlocProvider.of<CallLogCubit>(context).isSetUp();
        final String titleText = isSetup ? "Set up" : "Send dm";
        return Text(titleText);
      },
    );
  }
}

class AppBarSettingsButton extends StatelessWidget {
  const AppBarSettingsButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CallLogCubit, CallLogCubitState>(
      builder: (context, state) {
        final CallLogCubit cubit = BlocProvider.of<CallLogCubit>(context);
        final bool isSetup = cubit.isSetUp();
        return Visibility(
          visible: !isSetup,
          child: GestureDetector(
            child: const Padding(
              padding: EdgeInsets.only(right: 12.0),
              child: Icon(Icons.settings),
            ),
            onTap: () {
              Navigator.of(context).push(
                createRoute(
                  context,
                  BlocProvider.value(
                    value: cubit,
                    child: const ChangeCodeScreen(),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class PermissionRequiredWidget extends StatelessWidget {
  static const String loadingAnimationFilePath =
      "assets/animations/gears_infinite.json";
  static const String loadingAnimationDarkFilePath =
      "assets/animations/gears_infinite_dark.json";

  const PermissionRequiredWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final String animationPath =
        isDarkTheme ? loadingAnimationDarkFilePath : loadingAnimationFilePath;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Please allow phone permission"),
          Lottie.asset(animationPath),
          const PermissionButton(),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class PermissionButton extends StatelessWidget {
  const PermissionButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        final CallLogCubit cubit = BlocProvider.of<CallLogCubit>(context);
        return cubit.requestPermission();
      },
      child: const Text("Allow Permission"),
    );
  }
}

class SelectCountryCodeWidget extends StatefulWidget {
  const SelectCountryCodeWidget({
    Key? key,
    this.onTap,
  }) : super(key: key);
  final void Function(String? code)? onTap;

  @override
  State<SelectCountryCodeWidget> createState() =>
      _SelectCountryCodeWidgetState();
}

class _SelectCountryCodeWidgetState extends State<SelectCountryCodeWidget> {
  final List<CountryDetails?> countryCodes = CountryCodes.countryCodes();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text("Please Select your country code"),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: countryCodes.length,
            itemBuilder: (context, index) {
              CountryDetails? countryDetails = countryCodes[index];
              return ListTile(
                onTap: () {
                  if (widget.onTap != null) {
                    widget.onTap!(countryDetails?.dialCode);
                  }
                },
                dense: true,
                title: Text(countryDetails?.name ?? "unknown"),
              );
            },
          ),
        ),
      ],
    );
  }
}

class CallEntryList extends StatelessWidget {
  const CallEntryList({
    Key? key,
    required CallLogCubit cubit,
    required this.callLogs,
  })  : _cubit = cubit,
        super(key: key);

  final CallLogCubit _cubit;
  final List<CallLogEntry> callLogs;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: callLogs.length,
      itemBuilder: (context, index) {
        CallLogEntry entry = callLogs[index];
        DateTime date = DateTime.fromMillisecondsSinceEpoch(entry.timestamp!);
        return CallEntryListTile(entry: entry, cubit: _cubit, date: date);
      },
    );
  }
}

class CallEntryListTile extends StatelessWidget {
  const CallEntryListTile({
    Key? key,
    required this.entry,
    required CallLogCubit cubit,
    required this.date,
  })  : _cubit = cubit,
        super(key: key);

  final CallLogEntry entry;
  final CallLogCubit _cubit;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    String formatedDate =
        formatDate(date, [dd, "/", m, "/", yyyy, " ", HH, ":", mm]);
    return ListTile(
      onTap: () {
        if (entry.number == null) return;
        _cubit.openInWhatsapp(entry.number!);
      },
      leading: Icon(getCorrectIcon(entry.callType)),
      title: Text(
        entry.name ?? entry.formattedNumber ?? "Unknown Number",
      ),
      subtitle: Text("Date: $formatedDate"),
    );
  }

  IconData getCorrectIcon(CallType? type) {
    if (type == null) return CupertinoIcons.phone;
    if (type == CallType.incoming) return CupertinoIcons.phone_arrow_down_left;
    if (type == CallType.outgoing) return CupertinoIcons.phone_arrow_up_right;
    return CupertinoIcons.phone;
  }
}
