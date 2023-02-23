/* import 'package:hive_flutter/hive_flutter.dart';
import 'package:message_app/helper/local_storage.dart';
import '../models/chat_model.dart';
import '../models/user_model.dart';

class HiveStorage extends LocalStorage {
  late var userBox;
  late var contactsBox;
  late var messageBox;

  HiveStorage() {
    userBox = Hive.box('userBox');
    contactsBox = Hive.box('contactsBox');
    messageBox = Hive.box('messageBox');
  }
  createHive() async {
    await Hive.initFlutter();
    Hive.registerAdapter(UserModelAdapter());
    Hive.registerAdapter(ChatModelAdapter());
    return this;
  }

  @override
  void saveUserToLocal(UserModel myAccount) async {
    await userBox.put(0, myAccount);
  }

  @override
  void saveContactsToLocal(List<UserModel> myFriends) async {
    await contactsBox.clear();
    await contactsBox.add(myFriends);
  }

  @override
  UserModel getUserFromLocal() {
    return userBox.get(0);
  }

  @override
  List<UserModel> getContactsFromLocal() {
    return contactsBox.get(0);
  }

  @override
  void getMessageFromLocal() {
    // TODO: implement readMessageFromLocal
  }

  @override
  void saveMessageToLocal() {
    // TODO: implement saveMessageToLocal
  }

  @override
  clear() async {
    await userBox.clear();
    await contactsBox.clear();
    await messageBox.clear();
  }

  @override
  Future<bool> checkSignInFromLocal() {
    // TODO: implement checkSignInFromLocal
    throw UnimplementedError();
  }

  @override
  Future<void> setSignInToLocal() {
    // TODO: implement setSignInToLocal
    throw UnimplementedError();
  }
}
 */