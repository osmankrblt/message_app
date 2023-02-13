import '../models/user_model.dart';

abstract class LocalStorage {
  void saveUserToLocal(UserModel myAccount);
  UserModel getUserFromLocal();
  void saveContactsToLocal(List<UserModel> myFriends);
  List<UserModel> getContactsFromLocal();
  void saveMessageToLocal();
  void getMessageFromLocal();
  Future<bool> checkSignInFromLocal();
  Future<void> setSignInToLocal();
  clear();
}
