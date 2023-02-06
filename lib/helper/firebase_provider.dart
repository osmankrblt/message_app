import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:message_app/constants/my_constants.dart';
import 'package:message_app/pages/otp_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/utils.dart';
import '../models/user_model.dart';

class FirebaseProvider extends ChangeNotifier {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  bool _isSignedIn = false;
  bool _isLoading = false;

  String? _uid;
  String get uid => _uid!;

  UserModel? _userModel;
  UserModel get userModel => _userModel!;

  bool get isLoading => _isLoading;
  bool get isSignedIn => _isSignedIn;

  String? _phoneNumber;
  String get phoneNumber => _phoneNumber!;

  int? _resendToken;

  bool _codeSentButton = true;
  bool get codeSentButton => _codeSentButton;

  FirebaseProvider() {
    checkSignInFromSP();
  }

  Future syncUserProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      DocumentSnapshot snapshot =
          await _firebaseFirestore.collection("users").doc(_uid).get();

      _userModel = UserModel.fromMap(snapshot.data() as Map<String, dynamic>);

      await setUserModelToSP();
      await setSignInToSP();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print("Map hatası");
    }

    _isLoading = false;
    notifyListeners();
  }

// DATABASE PROCESS
  Future<void> updateData({
    required BuildContext context,
    required UserModel userModel,
    required File? profilePic,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();
      _userModel = userModel;

// upload image to firebase

      if (profilePic != null) {
        await saveImageToStorage("profilePic/$_uid", profilePic).then((value) {
          userModel.profilePic = value;
        });
      }

      _userModel = userModel;

      await _firebaseFirestore
          .collection("users")
          .doc(_uid)
          .update(userModel.toMap())
          .then((value) {
        _isLoading = false;
        notifyListeners();
      });

      await setUserModelToSP();
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message.toString());
      _isLoading = false;
      notifyListeners();
    }
  }

  Future saveUserToFirebase({
    required BuildContext context,
    required UserModel userModel,
    required File? profilePic,
    required Function onSuccess,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

// upload image to firebase

      if (profilePic != null) {
        await saveImageToStorage("profilePic/$_uid", profilePic).then((value) {
          userModel.profilePic = value;
        });
      }

      userModel.createdAt = DateTime.now().millisecondsSinceEpoch.toString();
      userModel.phoneNumber = auth.currentUser!.phoneNumber!;
      userModel.uid = auth.currentUser!.phoneNumber!;

      _userModel = userModel;

      await _firebaseFirestore
          .collection("users")
          .doc(_uid)
          .set(
            userModel.toMap(),
          )
          .then((value) {
        onSuccess();
        _isLoading = false;
        notifyListeners();
      });

      await setUserModelToSP();
      await setSignInToSP();
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message.toString());
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> saveImageToStorage(String ref, File file) async {
    UploadTask uploadTask = _firebaseStorage.ref().child(ref).putFile(file);

    TaskSnapshot snapshot = await uploadTask;

    String downloadUrl = await snapshot.ref.getDownloadURL();

    return downloadUrl;
  }

// AUTH PROCESS

  Future<bool> checkExistingUser() async {
    DocumentSnapshot snapshot =
        await _firebaseFirestore.collection("users").doc(_uid).get();

    if (snapshot.exists) {
      print("USER EXISTS");
      return true;
    } else {
      print("NEW USER");
      return false;
    }
  }

  Future checkSignInFromSP() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    _isSignedIn = s.getBool("is_signedin") ?? false;

    print("Giriş okundu... $_isSignedIn");
    notifyListeners();
  }

  Future setSignInToSP() async {
    final SharedPreferences s = await SharedPreferences.getInstance();

    s.setBool("is_signedin", true);

    print("Giriş kaydedildi ${s.getBool("is_signedin")}");
    _isSignedIn = true;
    notifyListeners();
  }

  Future setUserModelToSP() async {
    final SharedPreferences s = await SharedPreferences.getInstance();

    s.setString("user_model", jsonEncode(_userModel!.toMap()));

    print("Model kaydedildi");
  }

  Future getUserFromSP() async {
    SharedPreferences s = await SharedPreferences.getInstance();

    String data = s.getString("user_model") ?? "";
    _userModel = UserModel.fromMap(jsonDecode(data));

    notifyListeners();
  }

  Future<void> resendCode(BuildContext context) async {
    showSnackBar(context, "Otp code will sent...");
    await phoneVerify(context, phoneNumber);
  }

  Future<void> phoneVerify(BuildContext context, String phoneNumber) async {
    _codeSentButton = true;
    notifyListeners();
    try {
      _phoneNumber = phoneNumber;

      await auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await signIn(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          throw Exception(e.toString());
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
          _codeSentButton = false;
          showSnackBar(context, "Now, you can sent new otp code...");
          notifyListeners();
        },
        timeout: Duration(seconds: myConstants.codeTimeDuration),
      );
    } on FirebaseException catch (e) {
      showSnackBar(
        context,
        e.message.toString(),
      );
    }
  }

  void verifyOtp(
      {required BuildContext context,
      required String verificationId,
      required String userOtp,
      required Function onSuccess}) async {
    _isLoading = true;
    notifyListeners();

    try {
      PhoneAuthCredential _credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: userOtp,
      );

      User? user = (await auth.signInWithCredential(_credential)).user;

      if (user != null) {
        _uid = auth.currentUser!.uid;
        onSuccess();
      }
      _isLoading = false;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message.toString());
    }
  }

  Future<void> signIn(credential) async {
    try {
      // Sign the user in (or link) with the credential
      await auth.signInWithCredential(credential);
    } on FirebaseException catch (e) {
      return Future.error(e.message.toString());
    } catch (e) {
      return Future.error(e.toString());
    }
  }

  Future<void> signOut() async {
    try {
      await auth.signOut();
      _isSignedIn = false;
      notifyListeners();

      final SharedPreferences s = await SharedPreferences.getInstance();

      s.clear();
    } on FirebaseException catch (e) {
      return Future.error(e.message.toString());
    } catch (e) {
      return Future.error(e.toString());
    }
  }

  Future<void> deleteAccount() async {
    try {
      await _firebaseFirestore.collection("users").doc(_uid).delete();
      if (_userModel!.profilePic != "") {
        await _firebaseStorage.ref().child("profilePic/$_uid").delete();
      }

      final SharedPreferences s = await SharedPreferences.getInstance();
      s.clear();

      await auth.signOut();

      _isSignedIn = false;
      notifyListeners();
    } on FirebaseException catch (e) {
      return Future.error(e.message.toString());
    } catch (e) {
      return Future.error(e.toString());
    }
  }
}
