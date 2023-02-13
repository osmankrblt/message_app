import 'dart:io';
import 'package:flutter/material.dart';
import 'package:message_app/constants/my_constants.dart';
import 'package:message_app/constants/utils.dart';
import 'package:message_app/helper/database_provider.dart';
import 'package:message_app/widgets/custom_button.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../widgets/input_field_widget.dart';
import 'home_page.dart';

class UserInformationPage extends StatefulWidget {
  const UserInformationPage({super.key});

  @override
  State<UserInformationPage> createState() => _UserInformationPageState();
}

class _UserInformationPageState extends State<UserInformationPage> {
  File? image = null;

  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final bioController = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    nameController.dispose();

    bioController.dispose();
  }

  selectImage(BuildContext context) async {
    image = await pickImage();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final _isLoading =
        Provider.of<DatabaseProvider>(context, listen: true).isLoading;
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () => selectImage(context),
                        child: image == null
                            ? CircleAvatar(
                                backgroundColor: myConstants.themeColor,
                                radius: 65,
                                child: const Icon(
                                  Icons.account_circle,
                                  size: 50,
                                  color: Colors.white,
                                ),
                              )
                            : CircleAvatar(
                                radius: 65,
                                backgroundImage: FileImage(
                                  image!,
                                ),
                              ),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      InputField(
                        hintText: "Robert Downey Jr.",
                        controller: nameController,
                        icon: Icons.home,
                        inputType: TextInputType.name,
                        maxLine: 1,
                        maxCharacter: 25,
                        focus: false,
                        onChanged: (value) {
                          nameController.text = value;

                          setState(() {
                            nameController.selection =
                                TextSelection.fromPosition(
                              TextPosition(offset: nameController.text.length),
                            );
                          });
                        },
                      ),
                      InputField(
                        hintText: "You know who I am",
                        controller: bioController,
                        icon: Icons.text_fields_outlined,
                        inputType: TextInputType.name,
                        maxLine: 2,
                        maxCharacter: 40,
                        focus: false,
                        onChanged: (value) {
                          bioController.text = value;

                          setState(() {
                            bioController.selection =
                                TextSelection.fromPosition(
                              TextPosition(offset: bioController.text.length),
                            );
                          });
                        },
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: CustomButton(
                          text: "Sign In",
                          onPressed: () async {
                            if (await checkInternetStatus()) {
                              storeData();
                            } else {
                              showToast(
                                  "No internet to sign in.Try again later.");
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  void storeData() async {
    if (_formKey.currentState!.validate()) {
      final dp = Provider.of<DatabaseProvider>(context, listen: false);

      UserModel userModel = UserModel(
        name: nameController.text.trim(),
        bio: bioController.text,
        profilePic: "",
        createdAt: "",
        phoneNumber: "",
        uid: "",
        feel: "",
      );

      dp.saveUserToFirebase(
        userModel: userModel,
        profilePic: image,
        onSuccess: () {
          dp.setSignInToLocal().then(
                (value) => Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => HomePage(),
                    ),
                    (route) => false),
              );
        },
      );
    }
  }
}
