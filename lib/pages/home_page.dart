import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'chat_screen.dart';
import 'quick_user_info.dart';
import 'show_profile_photo.dart';
import 'welcome_screen.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late AuthProvider authProvider;
  late String currentUserId;
  final ScrollController listScrollController = ScrollController();

  int _limit = 20;
  int _limitIncrement = 20;

  List listMessageContacts = [];

  @override
  void initState() {
    super.initState();

    authProvider = context.read<AuthProvider>();
    if (authProvider.getUserFirebaseId()?.isNotEmpty == true) {
      currentUserId = authProvider.getUserFirebaseId()!;
    }
    listScrollController.addListener(scrollListener);
    WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
    // FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await getPermissions();

      bool result = await checkInternetStatus();
      if (result == true) {
        final cp = Provider.of<ContactsProvider>(context, listen: false);
        // final dp = Provider.of<DatabaseProvider>(context, listen: false);

        // await dp.syncUserProfile();
        await cp.syncAllContacts();
      } else {
        showToast("No internet :(");
      }
    });
    // FlutterNativeSplash.remove();
  }

  void scrollListener() {
    if (listScrollController.offset >=
            listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }

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
        body: Stack(
          children: [
            Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: StreamBuilder<DocumentSnapshot>(
                      stream: dp.getMyMessageList(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  myConstants.themeColor),
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text("Error"),
                          );
                        } else {
                          listMessageContacts = (snapshot.data!.data()
                              as Map<String, dynamic>)["messageUids"];

                          return listMessageContacts.length != 0
                              ? ListView.builder(
                                  padding: EdgeInsets.all(10.0),
                                  itemBuilder: (context, index) {
                                    //   UserModel? user =
                                    //     cp.getUserInfo(listMessageContacts[index]);
                                    return userListTile(
                                      UserModel(
                                        name: "test",
                                        profilePic: "",
                                        bio: "test",
                                        phoneNumber: "test",
                                        uid: "test",
                                        createdAt: "test",
                                        feel: "test",
                                      ),
                                    );
                                  },
                                  itemCount: listMessageContacts.length,
                                  reverse: false,
                                  controller: listScrollController,
                                )
                              : Center(
                                  child: Text(
                                    "You never texted",
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: myConstants.themeColor,
                                    ),
                                  ),
                                );
                        }
                      },
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget userListTile(UserModel user) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 5,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 80,
              width: 80,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      isScrollControlled: true,
                      isDismissible: false,
                      enableDrag: true,
                      context: context,
                      builder: (context) => QuickInfo(user: user),
                      backgroundColor: Colors.transparent,
                    );
                  },
                  child: showImageCircle(
                    user.profilePic,
                    140,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            InkWell(
              onTap: () {
                final String myUid =
                    Provider.of<DatabaseProvider>(context, listen: false).uid;
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      currentUserId: myUid,
                      peerUser: user,
                    ),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.55,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            user.bio,
                            maxLines: 2,
                            // softWrap: false,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(),
            ),
          ],
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
