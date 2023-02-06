import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:message_app/constants/my_constants.dart';
import 'package:message_app/pages/update_user_information_screen.dart';
import 'package:message_app/pages/user_information_screen.dart';
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

    return Scaffold(
        drawer: myDrawer(ap, context),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            color: Colors.purple,
          ),
        ));
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
                              try {
                                ap.signOut().then(
                                      (value) => Navigator.of(context)
                                          .pushAndRemoveUntil(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const WelcomeScreen(),
                                        ),
                                        (route) => false,
                                      ),
                                    );
                                ;
                              } catch (e) {
                                showSnackBar(context, e.toString());
                              }
                            },
                            child: Text("Sign Out"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              try {
                                ap.deleteAccount().then(
                                      (value) => Navigator.of(context)
                                          .pushAndRemoveUntil(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const WelcomeScreen(),
                                            ),
                                            (route) => false,
                                          )
                                          .then(
                                            (value) => showSnackBar(
                                              context,
                                              "Your account was deleted...",
                                            ),
                                          ),
                                    );
                                ;
                              } catch (e) {
                                showSnackBar(context, e.toString());
                              }
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
}
