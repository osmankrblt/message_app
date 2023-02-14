import 'dart:io';
import 'package:flutter/material.dart';
import 'package:message_app/constants/my_constants.dart';
import 'package:message_app/constants/utils.dart';
import 'package:provider/provider.dart';
import '../helper/database_provider.dart';
import '../widgets/get_my_widgets.dart';

class ProfilePhotoScreen extends StatefulWidget {
  String imgUrl;

  ProfilePhotoScreen({
    Key? key,
    required this.imgUrl,
  }) : super(key: key);

  @override
  State<ProfilePhotoScreen> createState() => _ProfilePhotoScreenState();
}

class _ProfilePhotoScreenState extends State<ProfilePhotoScreen> {
  File? image;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          backgroundColor: Colors.black,
          actions: [
            IconButton(
              icon: Icon(
                Icons.edit,
                color: Colors.white,
              ),
              onPressed: () {
                showModalBottomSheet(
                  backgroundColor: Colors.transparent,
                  context: context,
                  builder: (BuildContext context) {
                    return bottomSheetWidget();
                  },
                );
              },
            ),
          ],
        ),
        body: Material(
          color: Colors.black,
          child: Center(
            child: Container(
              color: Colors.black,
              child: image == null
                  ? showImageRectangle(widget.imgUrl, 480)
                  : Image.file(
                      image!,
                      fit: BoxFit.contain,
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget bottomSheetWidget() {
    return Container(
      height: 175,
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "Profile Photo",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                Expanded(
                  child: Container(),
                ),
                IconButton(
                  onPressed: () {
                    deleteImage(context);

                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.delete,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                InkWell(
                  onTap: () {},
                  child: Column(
                    children: [
                      Icon(
                        Icons.camera_alt,
                        color: myConstants.themeColor.shade300,
                        size: 35,
                      ),
                      Text(
                        "Camera",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 30,
                ),
                InkWell(
                  onTap: () {
                    selectImage(context);
                  },
                  child: Column(
                    children: [
                      Icon(
                        Icons.image,
                        color: myConstants.themeColor.shade300,
                        size: 35,
                      ),
                      Text(
                        "Gallery",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  selectImage(BuildContext context) async {
    final dp = Provider.of<DatabaseProvider>(context, listen: false);

    image = await pickImage();

    setState(() {});

    dp.updateProfilePhoto(profilePic: image);

    Navigator.pop(context);
  }

  deleteImage(BuildContext context) async {
    final dp = Provider.of<DatabaseProvider>(context, listen: false);

    dp.updateProfilePhoto(profilePic: null);

    Navigator.pop(context);
  }
}
