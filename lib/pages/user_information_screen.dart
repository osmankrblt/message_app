import 'dart:io';

import 'package:flutter/material.dart';
import 'package:message_app/constants/myColors.dart';
import 'package:message_app/constants/myGetterWidgets.dart';
import 'package:message_app/constants/utils.dart';
import 'package:message_app/widgets/custom_button.dart';
import 'package:provider/provider.dart';

import '../helper/firebase_provider.dart';
import '../models/user_model.dart';
import 'home_page.dart';

class UserInformationPage extends StatefulWidget {
  const UserInformationPage({super.key});

  @override
  State<UserInformationPage> createState() => _UserInformationPageState();
}

class _UserInformationPageState extends State<UserInformationPage> {
  File? image;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final bioController = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    nameController.dispose();
    emailController.dispose();
    bioController.dispose();
  }

  selectImage(BuildContext context) async {
    image = await pickImage(context);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final _isLoading =
        Provider.of<FirebaseProvider>(context, listen: true).isLoading;
    return Scaffold(
      appBar: myGetterWidgets.getAppbar(
        "User Information",
      ),
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
                    InkWell(
                      onTap: () => selectImage(context),
                      child: image == null
                          ? CircleAvatar(
                              backgroundColor: myColors.themeColor,
                              radius: 65,
                              child: const Icon(
                                Icons.account_circle,
                                size: 50,
                                color: Colors.white,
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
                      hintText: "abc@example.com",
                      controller: emailController,
                      icon: Icons.email,
                      inputType: TextInputType.emailAddress,
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
                        text: "Sign In",
                        onPressed: () {
                          storeData();
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
          fillColor: myColors.themeColor.shade50,
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
              color: myColors.themeColor,
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

  void storeData() async {
    final ap = Provider.of<FirebaseProvider>(context, listen: false);

    UserModel userModel = UserModel(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      bio: bioController.text,
      profilePic: "",
      createdAt: "",
      phoneNumber: "",
      uid: "",
    );

    if (image != null) {
      ap.saveUserToFirebase(
        context: context,
        userModel: userModel,
        profilePic: image!,
        onSuccess: () {
          ap.setUserModelToSP().then(
                (value) => ap.setSignInToSP().then(
                      (value) => Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => HomePage(),
                          ),
                          (route) => false),
                    ),
              );
        },
      );
    } else {
      showSnackBar(context, "Please upload your profile photo");
    }
  }
}
