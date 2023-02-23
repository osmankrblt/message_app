import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:message_app/constants/my_constants.dart';
import 'package:url_launcher/url_launcher.dart';

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

getDateToString(String messageDate) {
  DateTime tsdate = DateTime.now();

  if (messageDate == DateFormat("d/MM/y").format(tsdate)) {
    return "Today";
  } else if (DateFormat("d/MM/y").format(tsdate.subtract(Duration(days: 1))) ==
      messageDate) {
    return "Yesterday";
  } else {
    return messageDate;
  }
}

isDigits(String text) {
  try {
    double digits = double.parse(text);

    return true;
  } catch (e) {
    return false;
  }
}

richText(
  String text,
  bool isPeer,
  TextStyle textStyle,
) {
  return SelectableLinkify(
    onOpen: (link) async {
      late Uri task;
      if (link.url.contains("@")) {
        String content = Uri.encodeComponent(link.url);

        task = Uri.parse("mailto:$content");
      } else if (isDigits(link.url)) {
        String content = Uri.encodeComponent(link.url);

        task = Uri.parse("tel:$content");
      } else {
        String content = Uri.encodeComponent(link.url);

        task = Uri.parse("https:$content");
      }

      if (await canLaunchUrl(task)) {
        await launchUrl(task);
      } else {
        throw 'Could not launch $link';
      }
    },
    text: text,
    options: LinkifyOptions(
      looseUrl: true,
    ),
    maxLines: null,
    // softWrap: true,
    style: textStyle,
    linkStyle: TextStyle(
      color: isPeer ? myConstants.themeColor : Colors.white,
      fontSize: 15,
    ),
  );
}
