import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:url_launcher/url_launcher_string.dart';

void openInWhatsapp({
  required String number,
}) async {
  String whatsappUniversalLink = "https://wa.me/$number";
  if (await canLaunchUrlString(whatsappUniversalLink)) {
    launchUrlString(
      whatsappUniversalLink,
      mode: LaunchMode.externalApplication,
    );
  }
}

void openInTelegram({
  required String number,
}) async {
  String telegramUniversalLink = "https://t.me/$number";
  launchUrlString(
    telegramUniversalLink,
    mode: LaunchMode.externalApplication,
  );
}

void openInSms({
  required String number,
}) async {
  String smsLink = "sms:$number";
  if (await canLaunchUrlString(smsLink)) {
    launchUrlString(
      smsLink,
      mode: LaunchMode.externalApplication,
    );
  }
}

void callNumber({
  required String number,
}) async {
  await FlutterPhoneDirectCaller.callNumber(number);
}
