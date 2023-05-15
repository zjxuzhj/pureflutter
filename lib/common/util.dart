import 'package:flutter/material.dart';

class Util {
  static void dismissProgressDialog(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }
}
