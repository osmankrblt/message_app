import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
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
        body: SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
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
              length: 6,
              keyboardType: TextInputType.number,
              androidSmsAutofillMethod:
                  AndroidSmsAutofillMethod.smsRetrieverApi,
              onChanged: (value) {
                otpCode = value;
                setState(() {});
              },
            ),
            const SizedBox(
              height: 20.0,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: CustomButton(
                  text: "Verify",
                  onPressed: () {
                    verifyOtp(context, otpCode!);
                  }),
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
          await ap.checkExistingUser().then((value) async {
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
          });
        });
  }
}
