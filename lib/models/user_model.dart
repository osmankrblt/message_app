import 'dart:convert';
// import 'package:hive/hive.dart';

// part 'user_model.g.dart';

// @HiveType(typeId: 1)
class UserModel {
  // @HiveField(0)
  String name;
  // @HiveField(1)
  String profilePic;
  // @HiveField(2)
  String bio;
  // @HiveField(3)
  String phoneNumber;
  // @HiveField(4)
  String uid;
  // @HiveField(5)
  String createdAt;
  // @HiveField(6)
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
