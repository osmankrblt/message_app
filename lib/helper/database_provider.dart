import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:message_app/helper/local_storage.dart';
import '../constants/utils.dart';
import '../models/user_model.dart';

class DatabaseProvider extends ChangeNotifier {
  late FirebaseAuth _auth;
  late FirebaseFirestore _firebaseFirestore;
  late FirebaseStorage _firebaseStorage;
  late LocalStorage _localHelper;

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
    required LocalStorage localHelper,
    required FirebaseFirestore firebaseFirestore,
    required FirebaseAuth firebaseAuth,
    required FirebaseStorage firebaseStorage,
  }) {
    _localHelper = localHelper;
    _firebaseFirestore = firebaseFirestore;
    _firebaseStorage = firebaseStorage;
    _auth = firebaseAuth;

    checkSignInFromLocal();
  }
  Future<String> uploadImageToCloud(String ref, File file) async {
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

  Future checkSignInFromLocal() async {
    _isSignedIn = await _localHelper.checkSignInFromLocal();
    notifyListeners();
    print("Giriş okundu... $_isSignedIn");
  }

  Future setSignInToLocal() async {
    await _localHelper.setSignInToLocal();

    _isSignedIn = true;
    notifyListeners();
  }

  Future setUserModelToLocal() async {
    _localHelper.saveUserToLocal(_userModel!);

    print("Model kaydedildi");
  }

  Future getUserFromLocal() async {
    _userModel = _localHelper.getUserFromLocal();
    if (_userModel != null) {
      _uid = _auth.currentUser!.uid;
    }

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

      await setUserModelToLocal();
      await setSignInToLocal();

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

      _localHelper.clear();
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
      _localHelper.clear();
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

  Future<void> updateProfilePhoto({
    required File? profilePic,
  }) async {
    try {
      if (profilePic != null) {
        await uploadImageToCloud("profilePic/$_uid", profilePic).then((value) {
          _userModel!.profilePic = value;
        });
      } else {
        _userModel!.profilePic = "";
      }

      await _firebaseFirestore
          .collection("users")
          .doc(_uid)
          .update({"profilePic": _userModel!.profilePic});

      notifyListeners();
      await setUserModelToLocal();
    } on FirebaseAuthException catch (e) {
      showToast(
        "Update error - Profile Picture ",
      );
    } catch (e) {
      showToast(
        "Update error - Profile Picture ",
      );
    }
  }

  Future<void> updateBio({
    required String bio,
  }) async {
    try {
      _userModel!.bio = bio;
      await _firebaseFirestore
          .collection("users")
          .doc(_uid)
          .update({"bio": _userModel!.bio});
      await setUserModelToLocal();
    } on FirebaseAuthException catch (e) {
      showToast(
        "Update error - Bio ",
      );
    } catch (e) {
      showToast(
        "Update error - Bio ",
      );
    }
  }

  Future<void> updateName({
    required String name,
  }) async {
    try {
      _userModel!.name = name;
      await _firebaseFirestore
          .collection("users")
          .doc(_uid)
          .update({"name": _userModel!.name});
      await setUserModelToLocal();
    } on FirebaseAuthException catch (e) {
      showToast(
        "Update error - Name ",
      );
    } catch (e) {
      showToast(
        "Update error - Name ",
      );
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
        await uploadImageToCloud("profilePic/$_uid", profilePic).then((value) {
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

      await setUserModelToLocal();
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

      await setUserModelToLocal();
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
        await uploadImageToCloud("profilePic/$_uid", profilePic).then((value) {
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

      await setUserModelToLocal();
      await setSignInToLocal();
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
