import 'package:flutter/material.dart';
import 'package:message_app/widgets/get_my_widgets.dart';
import 'package:message_app/constants/my_constants.dart';
import 'package:message_app/helper/contacts_provider.dart';
import 'package:message_app/helper/database_provider.dart';
import 'package:message_app/pages/contacts_page.dart';
import 'package:message_app/widgets/input_field_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../constants/utils.dart';
import '../helper/auth_provider.dart';
import '../models/user_model.dart';
import 'show_profile_photo.dart';
import 'welcome_screen.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final cp = Provider.of<ContactsProvider>(context, listen: false);
    final dp = Provider.of<DatabaseProvider>(context, listen: false);
    final ap = Provider.of<AuthProvider>(context, listen: false);

    return SafeArea(
      child: Scaffold(
        drawer: myDrawer(context, ap, dp),
        appBar: getAppbar("Chatobur"),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await getPermissions();
            await cp.getAllContactsFromLocal();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ContactsPage(),
              ),
            );
          },
          child: const Icon(
            Icons.people_outline,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Container(
              color: Colors.purple,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "HomePage",
                  ),
                  Text(
                    dp.uid.toString(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  getPermissions() async {
    if (await Permission.contacts.request().isDenied) {
      // Either the permission was already granted before or the user just granted it.
      Map<Permission, PermissionStatus> statuses = await [
        Permission.contacts,
      ].request();
    }
    if (await Permission.contacts.request().isGranted) {
      // Either the permission was already granted before or the user just granted it.
      Map<Permission, PermissionStatus> statuses = await [
        Permission.contacts,
      ].request();
    }
  }

  Drawer myDrawer(BuildContext context, AuthProvider ap, DatabaseProvider dp) {
    UserModel _user =
        Provider.of<DatabaseProvider>(context, listen: true).userModel;
    return Drawer(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 2,
              child: UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  color: myConstants.themeColor,
                  image: const DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage("assets/mountain.jpg"),
                  ),
                ),
                currentAccountPicture: InkWell(
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            ProfilePhotoScreen(imgUrl: _user.profilePic),
                      ),
                    );
                  },
                  child: showImageCircle(
                    _user.profilePic,
                    480,
                  ),
                ),
                currentAccountPictureSize: const Size.square(
                  120,
                ),
                accountName: Row(
                  children: [
                    Flexible(
                      child: InkWell(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: ((context) => updateInputWidget(
                                  "Name",
                                  _user.name,
                                  1,
                                  25,
                                  (value) async {
                                    await dp
                                        .updateName(name: value)
                                        .whenComplete(
                                            () => Navigator.pop(context));
                                  },
                                )),
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                          );
                        },
                        child: Text(
                          _user.name,
                          style: const TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                accountEmail: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: ((context) => updateInputWidget(
                                  "Bio",
                                  _user.bio,
                                  2,
                                  40,
                                  (value) async {
                                    await dp.updateBio(bio: value).whenComplete(
                                        () => Navigator.pop(context));
                                  },
                                )),
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                          );
                        },
                        child: Text(
                          _user.bio,
                          maxLines: 2,
                          style: const TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage(
                      "assets/peoples.gif",
                    ),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              "How do you feel today?",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          emojiFeel(context, ap, dp),
                        ],
                      ),
                    ),
                    Expanded(child: Container()),
                    SizedBox(
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              alertDialog(
                                  context,
                                  [
                                    TextButton(
                                      onPressed: () {
                                        signOut(dp, context);
                                      },
                                      child: Text("Yes"),
                                    ),
                                    TextButton(
                                      onPressed: () {},
                                      child: Text("No"),
                                    ),
                                  ],
                                  "Are you sure you want to sign out?");
                            },
                            child: Text("Sign Out"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              alertDialog(
                                  context,
                                  [
                                    TextButton(
                                      onPressed: () {
                                        deleteAccount(dp, context);
                                      },
                                      child: Text("Yes"),
                                    ),
                                    TextButton(
                                      onPressed: () {},
                                      child: Text("No"),
                                    ),
                                  ],
                                  "Are you sure you want to delete account?");
                            },
                            child: Text("Delete Account"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  DropdownButton<String> emojiFeel(
      BuildContext context, AuthProvider ap, DatabaseProvider dp) {
    String emoji =
        Provider.of<DatabaseProvider>(context, listen: true).userModel.feel;

    return DropdownButton<String>(
      value: emoji != "" ? emoji : "",
      menuMaxHeight: MediaQuery.of(context).size.height * 0.3,
      items: myConstants.emojiList.map((String e) {
        return DropdownMenuItem<String>(
          value: e,
          child: Container(
            child: Text(
              e,
            ),
          ),
        );
      }).toList(),
      onChanged: ((feel) {
        dp.updateUserFeel(feel: feel.toString());
        setState(() {});
      }),
    );
  }

  void signOut(DatabaseProvider dp, BuildContext context) {
    try {
      dp.signOut().then(
            (value) => Navigator.of(context)
                .pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const WelcomeScreen(),
                  ),
                  (route) => false,
                )
                .then(
                  (value) => showToast(
                    "You are signed out",
                  ),
                ),
          );
    } catch (e) {
      showToast(
        "Sign Out",
      );
    }
  }

  void deleteAccount(DatabaseProvider dp, BuildContext context) {
    try {
      dp.deleteAccount().then(
            (value) => Navigator.of(context)
                .pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const WelcomeScreen(),
                  ),
                  (route) => false,
                )
                .then(
                  (value) => showToast(
                    "Your account was deleted",
                  ),
                ),
          );
    } catch (e) {
      showToast(
        "User profile error",
      );
    }
  }

  Widget updateInputWidget(String updateName, String hintText, int maxLine,
      int maxCharacter, Function onSuccess) {
    final _formKey = GlobalKey<FormState>();

    final controller = TextEditingController();

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Update your $updateName",
                  style: TextStyle(
                    fontSize: 30,
                    color: myConstants.themeColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Expanded(
                      child: InputField(
                        icon: Icons.new_releases,
                        controller: controller,
                        hintText: hintText,
                        inputType: TextInputType.text,
                        maxLine: maxLine,
                        maxCharacter: maxCharacter,
                        focus: true,
                        onChanged: (value) {
                          controller.text = value;

                          setState(() {
                            controller.selection = TextSelection.fromPosition(
                              TextPosition(offset: controller.text.length),
                            );
                          });
                        },
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        if (await checkInternetStatus()) {
                          if (_formKey.currentState!.validate()) {
                            onSuccess(controller.text);
                          }
                          ;
                        } else {
                          showToast("No internet to sign in.Try again later.");
                        }
                      },
                      icon: Icon(
                        Icons.send,
                        color: myConstants.themeColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
