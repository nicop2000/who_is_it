import 'package:flutter/cupertino.dart';

class Helper {

  static getHeadline(String message) => Text(
    message,
    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
  );

  static bool validatePasswordStrength(String value) {
    String pattern =
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&-_*~]).{8,}$';
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(value);
  }











}