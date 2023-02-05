import 'package:flutter/material.dart';

import 'package:message_app/constants/myGetterWidgets.dart';
import 'package:message_app/pages/phone_screen.dart';
import 'package:message_app/widgets/custom_button.dart';

import '../constants/utils.dart';
import 'otp_screen.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myGetterWidgets.getAppbar("Login Page"),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: CustomButton(
                  onPressed: (() => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PhoneScreen(),
                        ),
                      )),
                  text: "Login with Phone Number",
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
