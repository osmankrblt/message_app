import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:message_app/helper/local_storage.dart';
import 'package:message_app/models/user_model.dart';

class SharedPrefStorage extends LocalStorage {
  late SharedPreferences _prefs;

  createPref() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  @override
  Future<bool> checkSignInFromLocal() async {
    _prefs.reload();
    bool _isSignedIn = _prefs.getBool("is_signedin") ?? false;

    return _isSignedIn;
  }

  @override
  Future<void> setSignInToLocal() async {
    _prefs.setBool("is_signedin", true);
    print("Kaydedildi signin");
    _prefs.reload();
    print("Shared" + _prefs.toString());
  }

  @override
  void saveUserToLocal(UserModel myAccount) async {
    _prefs.setString(
      "user_model",
      jsonEncode(
        UserModel.toMap(myAccount),
      ),
    );
    _prefs.reload();
  }

  @override
  void saveContactsToLocal(List<UserModel> myFriends) {
    final String encodedData = UserModel.encode(myFriends);
    _prefs.setString(
      "my_friends",
      encodedData,
    );
  }

  @override
  UserModel getUserFromLocal() {
    _prefs.reload();

    String data = _prefs.getString("user_model") ?? "";
    return UserModel.fromMap(jsonDecode(data));
  }

  @override
  List<UserModel> getContactsFromLocal() {
    final String friendsString = _prefs.getString('my_friends') ?? "";

    if (friendsString != "") {
      print("Shared preferences arkadaş listesi " + friendsString);
      return UserModel.decode(friendsString);
    } else {
      return [];
    }
  }

  @override
  void getMessageFromLocal() {}

  @override
  void saveMessageToLocal() {}

  @override
  clear() async {
    _prefs.clear();
  }
}
