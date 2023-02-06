import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:message_app/constants/my_constants.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

import 'package:message_app/pages/home_page.dart';
import 'package:message_app/widgets/custom_button.dart';

import '../constants/utils.dart';
import '../helper/firebase_provider.dart';
import 'user_information_screen.dart';

class OtpScreen extends StatefulWidget {
  String verificationId;

  OtpScreen({
    Key? key,
    required this.verificationId,
  }) : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String? otpCode;

  @override
  Widget build(BuildContext context) {
    final ap = Provider.of<FirebaseProvider>(context, listen: true);

    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 250,
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  "assets/image3.png",
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              getVerify(),
            ],
          ),
        ));
  }

  Widget getVerify() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Column(
          children: [
            Pinput(
              closeKeyboardWhenCompleted: true,
              defaultPinTheme: PinTheme(
                width: 50,
                padding: const EdgeInsets.all(
                  13,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    5.0,
                  ),
                  color: myConstants.themeColor.shade300,
                  border: Border.all(
                    color: Colors.black12,
                  ),
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25.0,
                ),
              ),
              length: 6,
              keyboardType: TextInputType.number,
              androidSmsAutofillMethod: AndroidSmsAutofillMethod.none,
              onChanged: (value) {
                otpCode = value;
                setState(() {});
              },
            ),
            const SizedBox(
              height: 20.0,
            ),
            Container(
              margin: const EdgeInsets.all(
                5.0,
              ),
              padding: const EdgeInsets.all(
                5,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  5,
                ),
                border: Border.all(
                  width: 3,
                  color: myConstants.themeColor,
                ),
              ),
              child: Text(
                "${myConstants.codeTimeDuration.toString()}",
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: CustomButton(
                  text: "Verify",
                  onPressed: () {
                    verifyOtp(context, otpCode!);
                  }),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              "Didn't receive any code?",
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            IgnorePointer(
              ignoring: Provider.of<FirebaseProvider>(context, listen: true)
                  .codeSentButton,
              child: InkWell(
                onTap: () async {
                  final ap =
                      Provider.of<FirebaseProvider>(context, listen: false);

                  await ap.resendCode(context);
                },
                child: Text(
                  "Resend new code",
                  style: TextStyle(
                    fontSize: 16,
                    color: myConstants.themeColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void verifyOtp(BuildContext context, String userOtp) {
    final ap = Provider.of<FirebaseProvider>(context, listen: false);
    ap.verifyOtp(
      context: context,
      userOtp: userOtp,
      verificationId: widget.verificationId,
      onSuccess: () async {
        await ap.checkExistingUser().then(
          (value) async {
            value
                ? await ap
                    .syncUserProfile()
                    .whenComplete(() => Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HomePage(),
                          ),
                          (route) => false,
                        ))
                : Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UserInformationPage(),
                    ),
                  );
          },
        );
      },
    );
  }
}
