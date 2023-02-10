import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class ContactsProvider extends ChangeNotifier {
  late FirebaseFirestore _firebaseFirestore;
  late SharedPreferences _prefs;

  List<UserModel> _myFriends = [];
  List<UserModel> get myFriends => _myFriends;

  ContactsProvider({
    required SharedPreferences prefs,
    required FirebaseFirestore firebaseFirestore,
  }) {
    _prefs = prefs;
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

    return _temp;
  }

  setAllContactsToSP() {
    final String encodedData = UserModel.encode(_myFriends);
    _prefs.setString(
      "my_friends",
      encodedData,
    );
    print("Arkadaşlar kaydedildi ${_myFriends.length.toString()}");
    print("Arkadaşlar kaydedildi $encodedData");
  }

  getAllContactsFromSP() async {
    final SharedPreferences s = await SharedPreferences.getInstance();

    final String friendsString = s.getString('my_friends') ?? "";

    if (friendsString != "") {
      print("Shared preferences arkadaş listesi " + friendsString);
      _myFriends = UserModel.decode(friendsString);
      notifyListeners();
    } else {
      _myFriends = [];
    }

    print("Arkadaşlar okundu sayı ${_myFriends.length.toString()}");
  }

  syncAllContacts() async {
    List<String> _numberList = await _contactsTakeAllNumbers();
    List<UserModel> _temp = [];

    _numberList.forEach(
      (element) async {
        String _number = element.replaceAll(" ", "").trim();

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
        setAllContactsToSP();
      },
    );
  }
}
