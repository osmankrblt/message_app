import 'package:flutter/material.dart';
import 'package:message_app/constants/my_constants.dart';

AppBar getAppbar(title) {
  return AppBar(
    automaticallyImplyLeading: true,
    foregroundColor: myConstants.themeColor,
    title: Text(
      title,
      style: TextStyle(
        color: myConstants.appBarTitleColor,
      ),
    ),
    backgroundColor: myConstants.appBarBackgroundColor,
  );
}
