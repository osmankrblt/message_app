import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:message_app/helper/firebase_provider.dart';
import 'package:message_app/pages/login_page.dart';
import 'package:message_app/pages/home_page.dart';
import 'package:provider/provider.dart';
import 'constants/myColors.dart';

import 'package:firebase_core/firebase_core.dart';
import 'constants/utils.dart';
import 'firebase_options.dart';
import 'pages/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => FirebaseProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: myColors.themeColor,
          appBarTheme: myColors.myAppBarTheme,
        ),
        home: WelcomeScreen(),
      ),
    );
  }
}
