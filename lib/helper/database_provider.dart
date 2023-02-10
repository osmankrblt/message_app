import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/utils.dart';
import '../models/user_model.dart';

class DatabaseProvider extends ChangeNotifier {
  late FirebaseAuth _auth;
  late FirebaseFirestore _firebaseFirestore;
  late FirebaseStorage _firebaseStorage;
  late SharedPreferences _prefs;

  List<UserModel> _myFriends = [];
  List<UserModel> get myFriends => _myFriends;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;

  String? _uid;
  String get uid => _uid!;

  UserModel? _userModel;
  UserModel get userModel => _userModel!;

  DatabaseProvider({
    required SharedPreferences prefs,
    required FirebaseFirestore firebaseFirestore,
    required FirebaseAuth firebaseAuth,
    required FirebaseStorage firebaseStorage,
  }) {
    _prefs = prefs;
    _firebaseFirestore = firebaseFirestore;
    _firebaseStorage = firebaseStorage;
    _auth = firebaseAuth;

    checkSignInFromSP();
  }
  Future<String> saveImageToStorage(String ref, File file) async {
    UploadTask uploadTask = _firebaseStorage.ref().child(ref).putFile(file);

    TaskSnapshot snapshot = await uploadTask;

    String downloadUrl = await snapshot.ref.getDownloadURL();

    return downloadUrl;
  }

  Future<bool> checkExistingUser(String uid) async {
    _uid = uid;

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
    _prefs.reload();
    _isSignedIn = _prefs.getBool("is_signedin") ?? false;

    print("Giriş okundu... $_isSignedIn");
    notifyListeners();
  }

  Future setSignInToSP() async {
    _prefs.setBool("is_signedin", true);

    _isSignedIn = true;
    notifyListeners();
  }

  Future setUserModelToSP() async {
    _prefs.setString("user_model", jsonEncode(UserModel.toMap(_userModel!)));
    _prefs.reload();
    print("Model kaydedildi");
  }

  Future getUserFromSP() async {
    _prefs.reload();

    String data = _prefs.getString("user_model") ?? "";
    _userModel = UserModel.fromMap(jsonDecode(data));

    _uid = _auth.currentUser!.uid;
    notifyListeners();
    print("Current user uid $_uid");
  }

  Future syncUserProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      print("Hash" + _auth.currentUser.hashCode.toString());
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

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _isSignedIn = false;
      notifyListeners();

      _prefs.clear();
      _prefs.reload();
    } on FirebaseException catch (e) {
      print("Hata " + e.message.toString());
      showToast(e.message.toString());
    } catch (e) {
      print("Hata " + e.toString());
      showToast(e.toString());
    }
  }

  Future<void> deleteAccount() async {
    try {
      if (_userModel!.profilePic != "") {
        await _firebaseStorage.ref().child("profilePic/$_uid").delete();
      }

      await _firebaseFirestore.collection("users").doc(_uid).delete();
      _prefs.clear();
      await _auth.signOut();
      _isSignedIn = false;
      notifyListeners();
    } on FirebaseException catch (e) {
      print("Hata " + e.message.toString());
      showToast(e.message.toString());
    } catch (e) {
      print("Hata " + e.toString());
      showToast(e.toString());
    }
  }

  Future<void> updateUserProfile({
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
          .update(UserModel.toMap(userModel))
          .then((value) {
        _isLoading = false;
        notifyListeners();
      });

      await setUserModelToSP();
    } on FirebaseAuthException catch (e) {
      showToast(
        "Auth error",
      );
    } catch (e) {
      showToast(
        "Upload error",
      );
    }
  }

  Future<void> updateUserFeel({
    required String feel,
  }) async {
    try {
      _userModel!.feel = feel;
      notifyListeners();
      await _firebaseFirestore
          .collection("users")
          .doc(_uid)
          .update({"feel": feel});

      await setUserModelToSP();
    } on FirebaseAuthException catch (e) {
      showToast(
        "Auth error",
      );
    } catch (e) {
      showToast(
        "Upload error",
      );
    }
  }

  Future saveUserToFirebase({
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
      userModel.phoneNumber = _auth.currentUser!.phoneNumber!;
      userModel.uid = _auth.currentUser!.phoneNumber!;

      _userModel = userModel;

      await _firebaseFirestore
          .collection("users")
          .doc(_uid)
          .set(
            UserModel.toMap(userModel),
          )
          .then((value) {
        onSuccess();
        _isLoading = false;
        notifyListeners();
      });

      await setUserModelToSP();
      await setSignInToSP();
    } on FirebaseAuthException catch (e) {
      showToast(
        "Auth error",
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      showToast(
        "Upload error",
      );
      _isLoading = false;
      notifyListeners();
    }
  }
}
