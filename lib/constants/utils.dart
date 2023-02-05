import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

showSnackBar(BuildContext context, String? text) {
  if (text == null) return;

  final snackBar = SnackBar(
    content: Text(text),
    backgroundColor: Colors.red,
  );

  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text),
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
    showSnackBar(context, e.toString());
  }
  return image;
}
