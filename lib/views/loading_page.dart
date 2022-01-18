// ignore_for_file: implementation_imports

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/src/provider.dart';
import 'package:who_is_it/homepage.dart';
import 'package:who_is_it/model/user_model.dart';

class LoadingPage extends StatelessWidget {
  LoadingPage({Key? key}) : super(key: key);

  final String uid = FirebaseAuth.instance.currentUser!.uid;

  Future<BuildContext> _forward(BuildContext context) async {
    DocumentSnapshot userSnap =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    UserModel userModel =
        UserModel.fromJson(userSnap.data() as Map<String, dynamic>);
    context.read<UserModel>().setUserModel(userModel);
    context.read<UserModel>().lookAfterYourself();
    return context;
  }

  @override
  Widget build(BuildContext context) {
    _forward(context).then(
      (context) => Navigator.pushReplacement(
        context,
        CupertinoPageRoute(
          builder: (_) => const HomePage(),
        ),
      ),
    );

    return const CupertinoPageScaffold(
      child: SafeArea(
        child: Center(
          child: CupertinoActivityIndicator(),
        ),
      ),
    );
  }
}
