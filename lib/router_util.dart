import 'package:flutter/material.dart';

MaterialPageRoute createRoute(BuildContext context, Widget widget) {
  return MaterialPageRoute(
    builder: (context) {
      return widget;
    },
  );
}
