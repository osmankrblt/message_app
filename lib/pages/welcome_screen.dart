import 'package:flutter/material.dart';
import 'package:message_app/helper/auth_provider.dart';
import 'package:message_app/helper/database_provider.dart';
import 'package:message_app/pages/home_page.dart';
import 'package:provider/provider.dart';
import 'login_page.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dp = Provider.of<DatabaseProvider>(context, listen: false);
    final ap = Provider.of<AuthProvider>(context, listen: false);

    return StreamBuilder(
      stream: ap.authStateChanges(),
      builder: ((context, snapshot) {
        if (snapshot.connectionState != ConnectionState.active) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.connectionState == ConnectionState.active) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) async {
              await dp.checkSignInFromLocal().whenComplete(
                () async {
                  dp.isSignedIn
                      ? await dp.getUserFromLocal().whenComplete(() async {
                          await dp.checkExistingUser(dp.uid)
                              ? Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => HomePage(),
                                  ),
                                )
                              : Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LoginPage(),
                                  ),
                                );
                        })
                      : Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginPage(),
                          ),
                        );
                },
              );
            },
          );

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
