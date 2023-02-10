import 'dart:io';
import 'package:flutter/material.dart';
import 'package:message_app/constants/my_constants.dart';
import 'package:message_app/constants/utils.dart';
import 'package:message_app/helper/database_provider.dart';
import 'package:message_app/widgets/custom_button.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
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
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Value  musn't be empty";
          } else if (value.length < 10) {
            return "Value length must be at least 10 characters ";
          }
        },
        controller: controller,
        maxLines: maxLine,
        keyboardType: inputType,
        onChanged: (value) {
          controller.text = value;

          setState(() {
            controller.selection = TextSelection.fromPosition(
              TextPosition(offset: controller.text.length),
            );
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
          dp.setSignInToSP().then(
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
