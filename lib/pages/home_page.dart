import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:message_app/widgets/get_my_widgets.dart';
import 'package:message_app/constants/my_constants.dart';
import 'package:message_app/helper/contacts_provider.dart';
import 'package:message_app/helper/database_provider.dart';
import 'package:message_app/pages/contacts_page.dart';
import 'package:message_app/pages/update_user_information_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../constants/utils.dart';
import '../helper/auth_provider.dart';
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
            await cp.getAllContactsFromSP();
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
                  child: dp.userModel.profilePic != ""
                      ? CachedNetworkImage(
                          fit: BoxFit.cover,
                          imageUrl: dp.userModel.profilePic,
                          cacheKey: dp.userModel.profilePic,
                          imageBuilder: (context, imageProvider) =>
                              CircleAvatar(
                            backgroundImage: imageProvider,
                          ),
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
                        )
                      : CircleAvatar(
                          backgroundColor: myConstants.themeColor,
                          child: const Icon(
                            Icons.account_circle,
                            color: Colors.white,
                            size: 50,
                          ),
                        ),
                ),
                currentAccountPictureSize: const Size.square(
                  120,
                ),
                accountName: InkWell(
                  onTap: () {},
                  child: Text(
                    dp.userModel.name,
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
                accountEmail: InkWell(
                  onTap: () {},
                  child: Text(
                    dp.userModel.bio,
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 3,
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
                      padding: const EdgeInsets.all(8.0),
                      child: IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UpdateUserInformationPage(
                                userModel: dp.userModel,
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
}
