import 'package:flutter/material.dart';
import 'package:message_app/constants/my_constants.dart';
import 'package:message_app/helper/firebase_provider.dart';

class myGetterWidgets {
  myGetterWidgets._();
  static AppBar getAppbar(title) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          color: myConstants.appBarTitleColor,
        ),
      ),
      backgroundColor: myConstants.appBarBackgroundColor,
    );
  }
}
