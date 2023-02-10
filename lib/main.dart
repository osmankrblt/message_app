import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:message_app/helper/auth_provider.dart';
import 'package:message_app/helper/contacts_provider.dart';
import 'package:message_app/helper/database_provider.dart';

import 'constants/my_constants.dart';
import 'firebase_options.dart';
import 'pages/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  SharedPreferences prefs;

  MyApp({
    Key? key,
    required this.prefs,
  }) : super(key: key);
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            firebaseAuth: this.firebaseAuth,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ContactsProvider(
            firebaseFirestore: this.firebaseFirestore,
            prefs: this.prefs,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => DatabaseProvider(
            firebaseAuth: this.firebaseAuth,
            firebaseFirestore: this.firebaseFirestore,
            firebaseStorage: this.firebaseStorage,
            prefs: this.prefs,
          ),
        ),
      ],
      child: MaterialApp(
        title: "Let's chat 😶‍🌫️",
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: myConstants.themeColor,
          appBarTheme: myConstants.myAppBarTheme,
        ),
        home: WelcomeScreen(),
      ),
    );
  }
}
