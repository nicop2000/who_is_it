import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:who_is_it/model/opponent.dart';
import 'package:who_is_it/model/user_model.dart';

import 'package:who_is_it/views/add/tabs/add_category.dart';
import 'package:who_is_it/views/add/tabs/add_picture.dart';
import 'package:who_is_it/views/friends/friends_page.dart';
import 'package:who_is_it/views/add/tab_view_add.dart';
import 'package:who_is_it/views/user/login.dart';
import 'package:who_is_it/views/user/register.dart';
import 'package:who_is_it/views/welcome.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MultiProvider(
    child: const MyApp(),
    providers: [
      ChangeNotifierProvider(create: (_) => Opponent("", "")),
      ChangeNotifierProvider(create: (_) => UserModel("", [], [], []))
    ],
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Flutter Demo',
      initialRoute: '/',
      routes: {
        '/addPicture': (context) => const AddPicture(),
        '/addCategory': (context) => const AddCategory(),
        '/add': (context) => const TabViewController(),
        '/friends': (context) => const FriendsPage(),
        '/login': (context) => const Login(),
        '/register': (context) => const Register(),
        '/': (context) => const Welcome(),
      },
    );
  }

}
