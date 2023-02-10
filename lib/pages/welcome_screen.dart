import 'package:flutter/material.dart';
import 'package:message_app/helper/firebase_provider.dart';
import 'package:message_app/pages/home_page.dart';
import 'package:provider/provider.dart';
import 'login_page.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ap = Provider.of<FirebaseProvider>(context, listen: false);

    return StreamBuilder(
      stream: ap.auth.authStateChanges(),
      builder: ((context, snapshot) {
        if (snapshot.connectionState != ConnectionState.active) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.connectionState == ConnectionState.active) {
          debugPrint(ap.isSignedIn.toString());
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            ap.checkSignInFromSP().whenComplete(() async {
              ap.isSignedIn
                  ? await ap
                      .getUserFromSP()
                      .whenComplete(() => Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => HomePage(),
                            ),
                          ))
                  : Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginPage(),
                      ),
                    );
            });
          });

          return Container();
        } else {
          return const Center(
            child: Text("Something went wrong..."),
          );
        }
      }),
    );
  }
}
