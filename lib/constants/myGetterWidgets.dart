import 'package:flutter/material.dart';
import 'package:message_app/constants/myColors.dart';
import 'package:message_app/helper/firebase_provider.dart';

class myGetterWidgets {
  myGetterWidgets._();
  static AppBar getAppbar(title) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          color: myColors.appBarTitleColor,
        ),
      ),
      backgroundColor: myColors.appBarBackgroundColor,
    );
  }
}
