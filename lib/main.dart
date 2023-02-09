import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:who_is_it/homepage.dart';
import 'package:who_is_it/model/app.dart';
import 'package:who_is_it/model/opponent.dart';
import 'package:who_is_it/model/user_model.dart';

import 'package:who_is_it/views/add/tabs/add_category.dart';
import 'package:who_is_it/views/add/tabs/add_picture.dart';
import 'package:who_is_it/views/catalog.dart';
import 'package:who_is_it/views/friends/friends_page.dart';
import 'package:who_is_it/views/add/tab_view_add.dart';
import 'package:who_is_it/views/loading_page.dart';
import 'package:who_is_it/views/user/login.dart';
import 'package:who_is_it/views/user/register.dart';
import 'package:who_is_it/views/welcome.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

    await Firebase.initializeApp();

  //   await Firebase.initializeApp(
  //     options: FirebaseOptions(
  //         apiKey: "AIzaSyBDmEL-udQKrnSbNJc-qPheZIIzBxhk3lc",
  //         // Your apiKey
  //         appId: "1:612243160927::df27a6cde91d9af31800ea",
  //         // Your appId
  //         messagingSenderId: "612243160927",
  //         // Your messagingSenderId
  //         projectId: "who-is-it-31ad6",
  //         // Your projectId
  //         authDomain: "who-is-it-31ad6.firebaseapp.com",
  //         databaseURL: "https://who-is-it-31ad6-default-rtdb.europe-west1.firebasedatabase.app",
  //         storageBucket: "who-is-it-31ad6.appspot.com",
  //         measurementId: "G-RVM8V6Q3B5"
  //     ),
  //   );
  // }
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => Opponent("", "")),
      ChangeNotifierProvider(create: (_) => UserModel("", [], [], [])),
      ChangeNotifierProvider(create: (_) => App()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver  {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    setState(() {
    context.read<App>().setBrightness(WidgetsBinding.instance?.window.platformBrightness ?? Brightness.light);
    });
    super.didChangePlatformBrightness();
  }

  @override
  Widget build(BuildContext context) {
    context.read<App>().brightness = WidgetsBinding.instance?.window.platformBrightness ?? Brightness.light;
    return CupertinoApp(
      title: 'Wer ist es?',
      debugShowCheckedModeBanner: false,
      theme: getThemeData(context.watch<App>().brightness),
      initialRoute: '/',
      routes: {
        '/addPicture': (context) => const AddPicture(),
        '/addCategory': (context) => const AddCategory(),
        '/add': (context) => const TabViewController(),
        '/friends': (context) => const FriendsPage(),
        '/login': (context) => const Login(),
        '/register': (context) => const Register(),
        '/catalog': (context) => const Catalog(),
        '/': (context) => FirebaseAuth.instance.currentUser != null ? LoadingPage() : const Welcome(),
      },
    );
  }

  getThemeData(Brightness? brightness) {
    if (brightness == Brightness.dark) {
      return CupertinoThemeData(
        textTheme: CupertinoTextThemeData(textStyle: TextStyle(color: CupertinoColors.white)),
      );
    }
    return CupertinoThemeData(
      textTheme: CupertinoTextThemeData(textStyle: TextStyle(color: CupertinoColors.black)),
    );
  }
}
