import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:message_app/constants/myGetterWidgets.dart';
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
        appBar: myGetterWidgets.getAppbar("Send Emoji"),
        drawer: Drawer(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.purple,
                      backgroundImage: NetworkImage(
                        ap.userModel.profilePic,
                      ),
                      radius: 50,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      ap.userModel.name,
                    ),
                    Text(
                      ap.userModel.phoneNumber,
                    ),
                    Text(
                      ap.userModel.email,
                    ),
                    Text(
                      ap.userModel.bio,
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  try {
                    ap.signOut().then(
                          (value) => Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => const WelcomeScreen(),
                            ),
                            (route) => false,
                          ),
                        );
                    ;
                  } catch (e) {
                    showSnackBar(context, e.toString());
                  }
                },
                child: Text("SignOut"),
              ),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            color: Colors.purple,
          ),
        ));
  }
}
