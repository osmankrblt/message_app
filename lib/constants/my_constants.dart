import 'package:flutter/material.dart';

class myConstants {
  myConstants._();
  static var themeColor = Colors.blue;

  static double textFontSize = 25;
  static double customButtonHeight = 40;

  static int codeTimeDuration = 60;

  static var appBarTitleColor = themeColor.shade300;
  static var appBarBackgroundColor = Colors.white;

  static List<String> emojiList = [
    "",
    "😀",
    "😃",
    "😄",
    "😁",
    "😆",
    "😅",
    "😂",
    "🥲",
    "🥹",
    "😊",
    "😇",
    "🙂",
    "🙃",
    "😉",
    "😌",
    "😍",
    "🥰",
    "😘",
    "😗",
  ];

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
