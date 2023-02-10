import 'dart:convert';

class UserModel {
  String name;
  String profilePic;
  String bio;
  String phoneNumber;
  String uid;
  String createdAt;
  String feel;

  UserModel({
    required this.name,
    required this.profilePic,
    required this.bio,
    required this.phoneNumber,
    required this.uid,
    required this.createdAt,
    required this.feel,
  });

  // fromMap
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map["name"] ?? "",
      bio: map["bio"] ?? "",
      profilePic: map["profilePic"] ?? "",
      createdAt: map["createdAt"] ?? "",
      phoneNumber: map["phoneNumber"] ?? "",
      uid: map["uid"] ?? "",
      feel: map["feel"] ?? "",
    );
  }
// to map

  static Map<String, dynamic> toMap(UserModel user) {
    return {
      "name": user.name,
      "uid": user.uid,
      "bio": user.bio,
      "profilePic": user.profilePic,
      "phoneNumber": user.phoneNumber,
      "createdAt": user.createdAt,
      "feel": user.feel,
    };
  }

  static String encode(List<UserModel> users) => jsonEncode(
        users
            .map<Map<String, dynamic>>((user) => UserModel.toMap(user))
            .toList(),
      );

  static List<UserModel> decode(String friends) =>
      (jsonDecode(friends) as List<dynamic>)
          .map<UserModel>((item) => UserModel.fromMap(item))
          .toList();
}
