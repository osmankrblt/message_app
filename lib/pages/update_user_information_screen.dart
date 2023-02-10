import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:message_app/constants/my_constants.dart';
import 'package:message_app/constants/utils.dart';
import 'package:message_app/widgets/custom_button.dart';
import '../helper/firebase_provider.dart';
import '../models/user_model.dart';

class UpdateUserInformationPage extends StatefulWidget {
  UserModel userModel;

  UpdateUserInformationPage({
    Key? key,
    required this.userModel,
  }) : super(key: key);

  @override
  State<UpdateUserInformationPage> createState() =>
      _UpdateUserInformationPageState();
}

class _UpdateUserInformationPageState extends State<UpdateUserInformationPage> {
  File? image = null;

  final nameController = TextEditingController();

  final bioController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    nameController.text = widget.userModel.name;
    bioController.text = widget.userModel.bio;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    nameController.dispose();

    bioController.dispose();
  }

  selectImage() async {
    image = await pickImage();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final ap = Provider.of<FirebaseProvider>(context, listen: false);
    final _isLoading =
        Provider.of<FirebaseProvider>(context, listen: true).isLoading;
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.purple,
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25.0,
                  vertical: 5.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            Icons.arrow_back,
                            color: myConstants.themeColor,
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () => selectImage(),
                      child: image == null
                          ? CachedNetworkImage(
                              fit: BoxFit.contain,
                              imageUrl: ap.userModel.profilePic,
                              cacheKey: ap.userModel.profilePic,
                              imageBuilder: (context, imageProvider) =>
                                  CircleAvatar(
                                radius: 65,
                                backgroundImage: imageProvider,
                              ),
                              placeholder: (context, url) =>
                                  const CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  CircleAvatar(
                                backgroundColor: myConstants.themeColor,
                                child: const Icon(
                                  Icons.account_circle,
                                  color: Colors.white,
                                  size: 50,
                                ),
                              ),
                            )
                          : CircleAvatar(
                              radius: 65,
                              backgroundImage: FileImage(image!),
                            ),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    getInputField(
                      hintText: "Robert Downey Jr.",
                      controller: nameController,
                      icon: Icons.home,
                      inputType: TextInputType.name,
                      maxLine: 1,
                    ),
                    getInputField(
                      hintText: "You know who I am",
                      controller: bioController,
                      icon: Icons.text_fields_outlined,
                      inputType: TextInputType.name,
                      maxLine: 2,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: CustomButton(
                        text: "Update",
                        onPressed: () {
                          updateData();
                          showToast(
                            "Your profile will update...",
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget getInputField({
    required IconData icon,
    required TextEditingController controller,
    required String hintText,
    required TextInputType inputType,
    required int maxLine,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLine,
        keyboardType: inputType,
        onChanged: (value) {
          controller.text = value;

          setState(() {
            controller.selection = TextSelection.fromPosition(
                TextPosition(offset: controller.text.length));
          });
        },
        cursorColor: Colors.purple,
        style: TextStyle(
          fontSize: 16,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: myConstants.themeColor.shade50,
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.transparent,
            ),
            borderRadius: BorderRadius.circular(
              10.0,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.transparent,
            ),
            borderRadius: BorderRadius.circular(
              10.0,
            ),
          ),
          hintText: hintText,
          hintStyle: const TextStyle(
            fontSize: 16.0,
            color: Colors.black38,
          ),
          prefixIcon: Container(
            decoration: BoxDecoration(
              color: myConstants.themeColor,
              borderRadius: BorderRadius.circular(8.0),
            ),
            margin: EdgeInsets.all(
              8.0,
            ),
            child: Icon(
              icon,
              size: 20,
              color: Colors.white,
            ),
          ),
          alignLabelWithHint: true,
        ),
      ),
    );
  }

  void updateData() async {
    final ap = Provider.of<FirebaseProvider>(context, listen: false);

    widget.userModel.name = nameController.text;
    widget.userModel.bio = bioController.text;

    ap
        .updateData(
          userModel: widget.userModel,
          profilePic: image,
        )
        .then(
          (value) => Navigator.of(context).pop(),
        );
  }
}
