import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:who_is_it/model/category.dart';
import 'package:who_is_it/views/game.dart';
import 'package:provider/provider.dart';

import 'model/user_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? uid;
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Kindacode.com'),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(context.watch<UserModel>().name),
            CupertinoButton(
              child: const Text("Neues X hinzufügen"),
              onPressed: () => Navigator.pushNamed(context, '/add'),
            ),
            CupertinoButton(
              child: const Text("Registrieren"),
              onPressed: () => Navigator.pushNamed(context, '/register'),
            ),
            CupertinoButton(
              child: const Text("Freunde"),
              onPressed: () => Navigator.pushNamed(context, '/friends'),
            ),
            CupertinoButton(
                child: const Text("Mitspieler auswählen"),
                onPressed: () async {
                  List<CupertinoDialogAction> actions = await getOpponentOptions();
                  showCupertinoDialog(
                      context: context,
                      builder: (BuildContext bc) {
                        return CupertinoAlertDialog(
                            title: const Text("Mit wem möchtest du spielen"),
                            actions: actions,
                        );
                      });
                }),
            CupertinoButton(
                child: const Text("Spiel starten"),
                onPressed: uid == null ? null : () {
                  showCupertinoDialog(
                      context: context,
                      builder: (BuildContext bc) {
                        return StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('global')
                                .doc('categories')
                                .snapshots(),
                            builder: (BuildContext context,
                                AsyncSnapshot<
                                        DocumentSnapshot<Map<String, dynamic>>>
                                    snapshot) {
                              if (snapshot.hasData) {
                                List<dynamic> useData =
                                    snapshot.data!.data()!['names'];
                                List<CupertinoDialogAction> actions = useData
                                    .map(
                                      (e) => CupertinoDialogAction(
                                        child: Text(Category.fromJson(e).name),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          Navigator.push(
                                            context,
                                            CupertinoPageRoute(
                                              builder: (_) => Game(
                                                uidFriend: uid!,
                                                category: Category.fromJson(e),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                    .toList();
                                actions.add(CupertinoDialogAction(
                                    child: const Text("Abbrechen",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    onPressed: () =>
                                        Navigator.of(context).pop()));
                                return CupertinoAlertDialog(
                                  title: const Text("Kategorie"),
                                  content: Column(
                                    children: const [
                                      Text("Bitte wähle eine Kategorie aus"),
                                    ],
                                  ),
                                  actions: actions,
                                );
                              }
                              return const CupertinoActivityIndicator();
                            });
                      });
                }),
          ],
        ),
      ),
    );
  }

  Future<List<CupertinoDialogAction>> getOpponentOptions() async {
    List<CupertinoDialogAction> actions = [];
    for (String uid in context.read<UserModel>().friends) {
      DocumentSnapshot<Map<String, dynamic>> rawData =
          await FirebaseFirestore.instance.collection("users").doc(uid).get();
      if (rawData.data() != null) {
        actions.add(
          CupertinoDialogAction(
            child: Text(rawData.data()!['name']),
            onPressed: () {
              this.uid = uid;
              setState(() {

              });
              Navigator.of(context).pop();
            },
          ),
        );
      }
    }
    actions.add(CupertinoDialogAction(
        child: const Text("Abbrechen",
            style: TextStyle(
                fontWeight: FontWeight.bold)),
        onPressed: () =>
            Navigator.of(context).pop()));
    return actions;
  }
}
