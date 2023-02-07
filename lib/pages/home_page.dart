import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:message_app/constants/my_constants.dart';
import 'package:message_app/pages/contacts_page.dart';
import 'package:message_app/pages/update_user_information_screen.dart';
import 'package:message_app/pages/user_information_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../constants/utils.dart';
import '../helper/firebase_provider.dart';
import 'welcome_screen.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final ap = Provider.of<FirebaseProvider>(context, listen: false);

    return SafeArea(
      child: Scaffold(
          drawer: myDrawer(ap, context),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await getPermissions();

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
            child: Container(
              color: Colors.purple,
              child: Expanded(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [Text("HomePage")]),
              ),
            ),
          )),
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

  Drawer myDrawer(FirebaseProvider ap, BuildContext context) {
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
                  onTap: () {},
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    imageUrl: ap.userModel.profilePic,
                    cacheKey: ap.userModel.profilePic,
                    imageBuilder: (context, imageProvider) => CircleAvatar(
                      backgroundImage: imageProvider,
                    ),
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) => CircleAvatar(
                      backgroundColor: myConstants.themeColor,
                      child: const Icon(
                        Icons.account_circle,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                  ),
                ),
                currentAccountPictureSize: const Size.square(
                  120,
                ),
                accountName: InkWell(
                  onTap: () {},
                  child: Text(
                    ap.userModel.name,
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
                accountEmail: InkWell(
                  onTap: () {},
                  child: Text(
                    ap.userModel.bio,
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
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
                      padding: const EdgeInsets.all(8.0),
                      child: IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UpdateUserInformationPage(
                                userModel: ap.userModel,
                              ),
                            ),
                          ).then((value) {
                            showToast("Your profile updated");

                            setState(() {});
                          });
                        },
                        icon: Icon(
                          Icons.edit_outlined,
                          size: 35,
                          color: myConstants.themeColor,
                        ),
                      ),
                    ),
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
                                        signOut(ap, context);
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
                                        deleteAccount(ap, context);
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

  void signOut(FirebaseProvider ap, BuildContext context) {
    try {
      ap
          .signOut()
          .then(
            (value) => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const WelcomeScreen(),
              ),
              (route) => false,
            ),
          )
          .then(
            (value) => showToast(
              "You are signed out",
            ),
          );
      ;
    } catch (e) {
      showSnackBar(context, "Sign Out", e.toString(), ContentType.failure);
    }
  }

  void deleteAccount(FirebaseProvider ap, BuildContext context) {
    try {
      ap.deleteAccount().then(
            (value) => Navigator.of(context)
                .pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const WelcomeScreen(),
                  ),
                  (route) => false,
                )
                .then(
                  (value) => showSnackBar(context, "User profile",
                      "Your account was deleted...", ContentType.help),
                ),
          );
      ;
    } catch (e) {
      showSnackBar(context, "User profile", e.toString(), ContentType.failure);
    }
  }
}
