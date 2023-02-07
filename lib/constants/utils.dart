import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:message_app/constants/my_constants.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

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

showSnackBar(
    BuildContext context, String? title, String? text, ContentType type) {
  if (title == null || text == null || type == null) return;

  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: Colors.transparent,
      elevation: null,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height - 150,
      ),
      dismissDirection: DismissDirection.none,
      content: AwesomeSnackbarContent(
        title: title,
        message: text,
        contentType: type,
      ),
    ),
  );
}

Future<File?> pickImage(BuildContext context) async {
  File? image;
  try {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      image = File(pickedImage.path);
    }
  } catch (e) {
    showSnackBar(
        context, "Profile photo error", e.toString(), ContentType.failure);
  }
  return image;
}
