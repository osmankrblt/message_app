import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  late String content;
  late String image;
  late String timestamp;
  late String idFrom;
  late String idTo;
  ChatModel({
    required this.content,
    required this.image,
    required this.timestamp,
    required this.idFrom,
    required this.idTo,
  });
  Map<String, dynamic> toJson() {
    return {
      "idFrom": this.idFrom,
      "idTo": this.idTo,
      "timestamp": this.timestamp,
      "content": this.content,
      "image": this.image,
    };
  }

  factory ChatModel.fromMap(Map<String, String> map) {
    return ChatModel(
        content: map["content"] ?? "",
        image: map["image"] ?? "",
        timestamp: map["timestamp"] ?? "",
        idFrom: map["idFrom"] ?? "",
        idTo: map["idTo"] ?? "");
  }
  factory ChatModel.fromDoc(DocumentSnapshot doc) {
    return ChatModel(
      content: doc.get("content"),
      image: doc.get("image"),
      timestamp: doc.get("timestamp"),
      idFrom: doc.get("idFrom"),
      idTo: doc.get("idTo"),
    );
  }
}
