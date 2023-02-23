import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:message_app/helper/local_storage.dart';
import 'package:path/path.dart';
import '../constants/utils.dart';
import '../models/chat_model.dart';

class ChatProvider extends ChangeNotifier {
  late FirebaseFirestore _firebaseFirestore;
  late FirebaseStorage _firebaseStorage;

  late LocalStorage _localHelper;

  ChatProvider({
    required LocalStorage localHelper,
    required FirebaseFirestore firebaseFirestore,
    required FirebaseStorage firebaseStorage,
  }) {
    _localHelper = localHelper;
    _firebaseFirestore = firebaseFirestore;
    _firebaseStorage = firebaseStorage;
  }

  Future<String> uploadFileToCloud(String ref, File file) async {
    UploadTask uploadTask = _firebaseStorage.ref().child(ref).putFile(file);

    TaskSnapshot snapshot = await uploadTask;

    String downloadUrl = await snapshot.ref.getDownloadURL();

    return downloadUrl;
  }

  void sendChatMessage(String content, File? image, File? file,
      String groupChatId, String currentUserId, String peerId) async {
    try {
      String timeNow = DateTime.now().millisecondsSinceEpoch.toString();

      ChatModel message = ChatModel(
        content: content,
        image: "",
        timestamp: DateTime.now().millisecondsSinceEpoch.toString(),
        idFrom: currentUserId,
        idTo: peerId,
      );

      _firebaseFirestore.collection('messages').doc(groupChatId).set({});
      _firebaseFirestore.collection('message_lists').doc(currentUserId).update(
        {
          "messageUids": FieldValue.arrayUnion([peerId]),
        },
      );

      DocumentReference documentReference = _firebaseFirestore
          .collection("messages")
          .doc(groupChatId)
          .collection(groupChatId)
          .doc(timeNow);

      if (image != null) {
        await uploadFileToCloud(
          "images/$currentUserId/$peerId-$timeNow}",
          image,
        ).then(
          (value) {
            message.image = value;
          },
        );
      }
      if (file != null) {
        await uploadFileToCloud(
          "files/$currentUserId/$peerId-${basename(file.path)}-$timeNow}",
          file,
        ).then(
          (value) {
            message.image = value;
          },
        );
      }
      _firebaseFirestore.runTransaction((transaction) async {
        await transaction.set(
          documentReference,
          message.toJson(),
        );
      });
    } catch (e) {
      showToast(
        "Message couldnt sent ",
      );
    }
  }

  Future<void> updateFirestoreData(
      String collectionPath, String docPath, Map<String, dynamic> dataUpdate) {
    return _firebaseFirestore
        .collection(collectionPath)
        .doc(docPath)
        .update(dataUpdate);
  }

  Stream<QuerySnapshot> getChatMessage(String groupChatId, int limit) {
    return _firebaseFirestore
        .collection("messages")
        .doc(groupChatId)
        .collection(groupChatId)
        .orderBy("timestamp", descending: true)
        .limit(limit)
        .snapshots();
  }

  syncMessages() {}

  Future<String> getLastMessages(String groupChatId, int limit) async {
    QuerySnapshot snapshot = await _firebaseFirestore
        .collection("messages")
        .doc(groupChatId)
        .collection(groupChatId)
        .orderBy("timestamp", descending: true)
        .get();
    return ChatModel.fromDoc(snapshot.docs.first).content.toString();
  }
}
