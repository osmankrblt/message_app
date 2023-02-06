class UserModel {
  String name;
  String profilePic;

  String bio;
  String phoneNumber;
  String uid;
  String createdAt;

  UserModel({
    required this.name,
    required this.profilePic,
    required this.bio,
    required this.phoneNumber,
    required this.uid,
    required this.createdAt,
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
    );
  }
// to map

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "uid": uid,
      "bio": bio,
      "profilePic": profilePic,
      "phoneNumber": phoneNumber,
      "createdAt": createdAt
    };
  }
}
