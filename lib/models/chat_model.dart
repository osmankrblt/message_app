import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'chat_model.g.dart';

@HiveType(typeId: 0)
class ChatModel {
  @HiveField(0)
  late String content;
  @HiveField(1)
  late String image;
  @HiveField(2)
  late String timestamp;
  @HiveField(3)
  late String idFrom;
  @HiveField(4)
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
