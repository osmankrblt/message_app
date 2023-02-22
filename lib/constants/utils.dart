import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:message_app/constants/my_constants.dart';

checkInternetStatus() async {
  final connectivityResult = await (Connectivity().checkConnectivity());

  if (connectivityResult == ConnectivityResult.mobile ||
      connectivityResult == ConnectivityResult.wifi) {
    return true;
  } else if (connectivityResult == ConnectivityResult.none) {
    return false;
  }
}

alertDialog(BuildContext context, List<Widget> buttons, String? content) {
  if (content == null) return;

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    content: Text(content),
    actions: buttons,
  );
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

showToast(String? content) {
  if (content == null) return;
  Fluttertoast.cancel();
  Fluttertoast.showToast(
    msg: content,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.TOP,
    timeInSecForIosWeb: 1,
    backgroundColor: myConstants.themeColor,
    fontSize: 16.0,
  );
}

Future<File?> pickImage() async {
  File? image;
  try {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      image = File(pickedImage.path);
    }
  } catch (e) {
    showToast(
      "Profile photo error",
    );
  }
  return image;
}

Future<File?> pickFile() async {
  File? file;
  try {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      file = File(result.files.single.path!);
    } else {
      file = null;
    }
  } catch (e) {
    showToast(
      "File upload error",
    );
  }
  return file;
}

getGroupChatId({required currentId, required peerId}) {
  if (currentId.hashCode <= peerId.hashCode) {
    return '$currentId-$peerId';
  } else {
    return '$peerId-$currentId';
  }
}
