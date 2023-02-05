import 'package:flutter/material.dart';

class myColors {
  myColors._();
  static var themeColor = Colors.purple;

  static double textFontSize = 25;

  static var appBarTitleColor = Colors.purple.shade300;
  static var appBarBackgroundColor = Colors.white;
  static AppBarTheme myAppBarTheme = AppBarTheme(
    backgroundColor: appBarBackgroundColor,
    elevation: 5,
    titleTextStyle: TextStyle(
      color: appBarTitleColor,
      fontSize: textFontSize,
      fontWeight: FontWeight.bold,
    ),
  );

  static InputBorder myInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(15),
  );
}
