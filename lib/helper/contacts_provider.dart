import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:message_app/helper/local_storage.dart';
import '../models/user_model.dart';

class ContactsProvider extends ChangeNotifier {
  late FirebaseFirestore _firebaseFirestore;

  late LocalStorage _localHelper;

  List<UserModel> _myFriends = [];
  List<UserModel> get myFriends => _myFriends;

  ContactsProvider({
    required LocalStorage localHelper,
    required FirebaseFirestore firebaseFirestore,
  }) {
    _localHelper = localHelper;
    _firebaseFirestore = firebaseFirestore;
  }

//Friends funcs
  _contactsTakeAllNumbers() async {
    List<Contact> contacts =
        await ContactsService.getContacts(withThumbnails: false);
    ;

    List<String> _temp = [];
    contacts.forEach((element) {
      element.phones!.isNotEmpty
          ? _temp.add(element.phones!.first.value.toString())
          : null;
    });
    print("Rehberdeki kişi sayısı " + _temp.length.toString());
    return _temp;
  }

  setAllContactsToLocal() {
    _localHelper.saveContactsToLocal(_myFriends);
    print("Arkadaşlar kaydedildi ${_myFriends.length.toString()}");
  }

  getAllContactsFromLocal() async {
    _myFriends = _localHelper.getContactsFromLocal();
    notifyListeners();
    print("Arkadaşlar okundu sayı ${_myFriends.length.toString()}");
  }

  syncAllContacts() async {
    List<String> _numberList = await _contactsTakeAllNumbers();
    List<UserModel> _temp = [];

    _numberList.forEach(
      (element) async {
        String _number = element.replaceAll(RegExp('[^0-9]'), "").trim();

        _number = _number.startsWith("90") ? "+" + _number : "+9" + _number;

        QuerySnapshot snapshot = await _firebaseFirestore
            .collection("users")
            .where(
              "phoneNumber",
              isEqualTo: _number,
            )
            .get(
              GetOptions(
                source: Source.server,
              ),
            );

        if (snapshot.docs.isNotEmpty) {
          Map<String, dynamic> _user =
              snapshot.docs.first.data() as Map<String, dynamic>;
          _temp.add(
            UserModel.fromMap(_user),
          );
          _myFriends = _temp;

          notifyListeners();
        }
        setAllContactsToLocal();
      },
    );
  }
}
