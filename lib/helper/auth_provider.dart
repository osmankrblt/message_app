import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:message_app/constants/my_constants.dart';
import 'package:message_app/pages/otp_screen.dart';
import '../constants/utils.dart';

class AuthProvider extends ChangeNotifier {
  late FirebaseAuth _auth;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _phoneNumber;
  String get phoneNumber => _phoneNumber!;

  int? _resendToken;

  AuthProvider({
    required FirebaseAuth firebaseAuth,
  }) {
    _auth = firebaseAuth;
  }

// AUTH PROCESS

  authStateChanges() {
    return _auth.authStateChanges();
  }

  Future<void> resendCode(BuildContext context) async {
    showToast(
      "Otp code will sent...",
    );
    await phoneVerify(context, phoneNumber);
  }

  Future<void> phoneVerify(BuildContext context, String phoneNumber) async {
    notifyListeners();
    try {
      _phoneNumber = phoneNumber;

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await signIn(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          showToast("Verification failed.Wrong number");
        },
        codeSent: (String verificationId, int? resendToken) async {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => OtpScreen(
                verificationId: verificationId,
              ),
            ),
          );
          _resendToken = resendToken;
        },
        forceResendingToken: _resendToken,
        codeAutoRetrievalTimeout: (String verificationId) {
          print("Kod süresi doldu");
        },
        timeout: Duration(seconds: myConstants.codeTimeDuration),
      );
    } on FirebaseException catch (e) {
      showToast(
        "Auth Error",
      );
    } catch (e) {
      showToast(
        "Upload error",
      );
      _isLoading = false;
      notifyListeners();
    }
  }

  void verifyOtp(
      {required String verificationId,
      required String userOtp,
      required Function onSuccess}) async {
    _isLoading = true;
    notifyListeners();

    try {
      PhoneAuthCredential _credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: userOtp,
      );
      final result = (await _auth.signInWithCredential(_credential));

      User? user = result.user;
      if (user != null) {
        String _uid = _auth.currentUser!.uid;
        onSuccess(_uid);
      }

      _isLoading = false;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      showToast(
        "Auth error",
      );
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signIn(credential) async {
    try {
      // Sign the user in (or link) with the credential
      await _auth.signInWithCredential(credential);
    } on FirebaseException catch (e) {
      return Future.error(e.message.toString());
    } catch (e) {
      return Future.error(e.toString());
    }
  }
}
