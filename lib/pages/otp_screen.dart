import 'dart:async';
import 'package:flutter/material.dart';
import 'package:message_app/constants/my_constants.dart';
import 'package:message_app/constants/utils.dart';
import 'package:message_app/helper/database_provider.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:message_app/pages/home_page.dart';
import 'package:message_app/widgets/custom_button.dart';
import '../helper/auth_provider.dart';
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
  int resendTime = myConstants.codeTimeDuration;
  Timer? timer;
  bool resendOtpButton = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    timer = Timer(
      Duration(seconds: myConstants.codeTimeDuration),
      () {
        showToast(
          "Now, you can sent new otp code...",
        );
        resendOtpButton = true;
      },
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _isLoading =
        Provider.of<AuthProvider>(context, listen: true).isLoading;
    timer;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Colors.purple,
                  ),
                )
              : Column(
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
                "${resendTime}",
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: CustomButton(
                  text: "Verify",
                  onPressed: () async {
                    if (await checkInternetStatus()) {
                      verifyOtp(context, otpCode!);
                    } else {
                      showToast("No internet to verify");
                    }
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
            InkWell(
              onTap: () async {
                if (resendOtpButton) {
                  final ap = Provider.of<AuthProvider>(context, listen: false);

                  await ap.resendCode(context);
                } else {
                  showToast(
                      "You cant sent new otp code until end of the resend time ");
                }
              },
              child: Text(
                "Resend new code",
                style: TextStyle(
                  fontSize: 16,
                  color: myConstants.themeColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void verifyOtp(BuildContext context, String userOtp) {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    final dp = Provider.of<DatabaseProvider>(context, listen: false);
    ap.verifyOtp(
      userOtp: userOtp,
      verificationId: widget.verificationId,
      onSuccess: (String uid) async {
        debugPrint("Uid $uid");
        await dp.checkExistingUser(uid).then(
          (value) async {
            value
                ? await dp.syncUserProfile().whenComplete(
                      () => Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HomePage(),
                        ),
                        (route) => false,
                      ),
                    )
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
