import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:message_app/helper/auth_provider.dart';
import 'package:message_app/helper/contacts_provider.dart';
import 'package:message_app/helper/database_provider.dart';
import 'package:message_app/helper/hive_storage.dart';
import 'package:message_app/helper/local_storage.dart';
import 'package:message_app/helper/shared_pref_storage.dart';
import 'package:message_app/models/chat_model.dart';

import 'constants/my_constants.dart';
import 'firebase_options.dart';
import 'models/user_model.dart';
import 'pages/welcome_screen.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  //FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  //final LocalStorage hiveStorage = await HiveStorage().createHive();
  final LocalStorage storageHelper = await SharedPrefStorage().createPref();

  runApp(MyApp(storageHelper: storageHelper));
}

class MyApp extends StatelessWidget {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  LocalStorage storageHelper;

  MyApp({
    Key? key,
    required this.storageHelper,
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
              localHelper: this.storageHelper),
        ),
        ChangeNotifierProvider(
          create: (_) => DatabaseProvider(
            firebaseAuth: this.firebaseAuth,
            firebaseFirestore: this.firebaseFirestore,
            firebaseStorage: this.firebaseStorage,
            localHelper: this.storageHelper,
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
