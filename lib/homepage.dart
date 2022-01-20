import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:who_is_it/model/app.dart';
import 'package:who_is_it/model/category.dart';
import 'package:who_is_it/model/opponent.dart';
import 'package:who_is_it/views/game.dart';
import 'package:provider/provider.dart';
import 'package:who_is_it/views/welcome.dart';

import 'model/user_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>{


  List<Category> categories = [];
  final user = FirebaseAuth.instance.currentUser!;
  final users = FirebaseFirestore.instance.collection("users");

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Menü'),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: GridView(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery
                  .of(context)
                  .size
                  .width > 500 ? 4 : 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 20),
          children: [
            getMenuButton(
                iconData: CupertinoIcons.burst,
                title: context
                    .watch<Opponent>()
                    .name
                    .isEmpty
                    ? "Gegenspieler auswählen"
                    : "Gegenspieler: ${context
                    .read<Opponent>()
                    .name}",
                onTap: () => chooseOpponent()),
            getMenuButton(
                iconData: CupertinoIcons.clear,
                title: "Gegenspieler zurücksetzen",
                onTap: context
                    .watch<Opponent>()
                    .uid
                    .isEmpty
                    ? null
                    : () => context.read<Opponent>().reset()),
            getMenuButton(
                iconData: CupertinoIcons.book,
                title: "Kategorie(n) auswählen",
                onTap: () => chooseCategories()),
            getMenuButton(
                iconData: CupertinoIcons.clear,
                title: "Kategorien zurücksetzen",
                onTap: categories.isEmpty
                    ? null
                    : () =>
                    setState(() {
                      categories.clear();
                    })),
            getMenuButton(
                iconData: CupertinoIcons.play,
                title: "Spiel starten",
                onTap: (context
                    .watch<Opponent>()
                    .uid
                    .isEmpty ||
                    categories.isEmpty)
                    ? null
                    : () => playGame()),
            getMenuButton(
                iconData: CupertinoIcons.group,
                title: "Freunde",
                onTap: () => Navigator.pushNamed(context, '/friends')),
            getMenuButton(
                iconData: CupertinoIcons.add,
                title: "Hinzufügen",
                onTap: () => Navigator.pushNamed(context, '/add')),
            getMenuButton(
                iconData: CupertinoIcons.lock,
                title: "Ausloggen",
                onTap: () =>
                    FirebaseAuth.instance.signOut().then((value) {
                      context.read<UserModel>().callItADay();
                      Navigator.of(context).pushReplacement(
                          CupertinoPageRoute(builder: (_) => const Welcome()));
                    })),
            getMenuButton(
                iconData: CupertinoIcons.delete_solid,
                title: "Account löschen",
                onTap: () => deleteConfirmation(context)),
          ],
        ),
      ),
    );
  }

  Future<List<CupertinoDialogAction>> getOpponentOptions() async {
    List<CupertinoDialogAction> actions = [];
    for (String uid in context
        .read<UserModel>()
        .friends) {
      DocumentSnapshot<Map<String, dynamic>> rawData =
      await FirebaseFirestore.instance.collection("users").doc(uid).get();
      if (rawData.data() != null) {
        actions.add(
          CupertinoDialogAction(
            child: Text(rawData.data()!['name']),
            onPressed: () {
              context
                  .read<Opponent>()
                  .setData(uid: uid, name: rawData.data()!['name']);
              Navigator.of(context).pop();
            },
          ),
        );
      }
    }
    actions.add(CupertinoDialogAction(
        child: const Text("Abbrechen",
            style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () => Navigator.of(context).pop()));
    return actions;
  }

  getMenuButton(
          {required IconData iconData,
        required String title,
        required Function? onTap}) {
    return Card(
      elevation: 3.5,
      shadowColor: context.watch<App>().brightness == Brightness.dark ? CupertinoColors.white : null,
      color: context.watch<App>().brightness == Brightness.dark ? Color.fromRGBO(27, 27, 27, 1.0) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
      child: InkWell(
        onTap: onTap == null ? null : () => onTap(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              iconData,
              size: 40,
              color: onTap == null
                  ? CupertinoColors.systemGrey
                  : CupertinoColors.activeBlue,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, color: context.watch<App>().brightness == Brightness.dark ? CupertinoColors.white : null),
              ),
            )
          ],
        ),
      ),
    );
  }

  chooseOpponent() async {
    List<CupertinoDialogAction> actions = await getOpponentOptions();
    showCupertinoDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext bc) {
          return CupertinoAlertDialog(
            title: const Text("Mit wem möchtest du spielen"),
            actions: actions,
          );
        });
  }

  chooseCategories() {
    showCupertinoDialog(
        context: context,
        builder: (BuildContext bc) {
          return StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('global')
                  .doc('categories')
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                  snapshot) {
                if (snapshot.hasData) {
                  List<dynamic> useData = snapshot.data!.data()!['names'];
                  useData.sort((a, b) =>
                      a['name'].toString().compareTo(b['name'].toString()));

                  return StatefulBuilder(builder:
                      (BuildContext context, StateSetter selectedState) {
                    List<CupertinoDialogAction> actions = useData.map((e) {
                      Category category = Category.fromJson(e);
                      return CupertinoDialogAction(
                        child: FutureBuilder(
                            future: getPictureCount(category),
                            builder: (BuildContext context,
                                AsyncSnapshot<int> snapshot) {
                              if (snapshot.hasData) {
                                return Text(
                                  "${category.name} (${snapshot.data!} Bilder)",
                                  style: TextStyle(
                                      color: categories.containsCategory(
                                          category)
                                          ? CupertinoColors.activeGreen
                                          : CupertinoColors.systemGrey),
                                );
                              }
                              return const Text("Lädt...");
                            }),
                        onPressed: () {
                          if (categories.containsCategory(category)) {
                            categories.removeWhere(
                                    (element) => element.name == category.name);
                          } else {
                            categories.add(category);
                          }
                          selectedState(() {});
                        },
                      );
                    }).toList();
                    actions.add(CupertinoDialogAction(
                      child: Text(categories.isNotEmpty
                          ? "Auswahl löschen"
                          : "Alle hinzufügen"),
                      onPressed: () {
                        if (categories.isNotEmpty) {
                          categories.clear();
                        } else {
                          for (var categoryJSON in useData) {
                            categories.add(Category.fromJson(categoryJSON));
                          }
                        }
                        selectedState(() {});
                      },
                    ));
                    actions.add(CupertinoDialogAction(
                        child: const Text("OK",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: () =>
                            setState(() {
                              Navigator.of(context).pop();
                            })));
                    return CupertinoAlertDialog(
                      title: const Text("Kategorie"),
                      content: Column(
                        children: const [
                          Text(
                              "Bitte wähle eine oder mehrere Kategorie(n) aus"),
                        ],
                      ),
                      actions: actions,
                    );
                  });
                }
                return const CupertinoActivityIndicator();
              });
        });
  }

  Future<int> getPictureCount(Category category) async {
    ListResult pictures = await FirebaseStorage.instance.ref(
        category.name.toLowerCase().replaceAll(" ", "-")).listAll();
    return pictures.items.length;
  }

  playGame() async {
    TextEditingController bilderZahl = TextEditingController();
    bilderZahl.text = "40";
    showCupertinoDialog(
        context: context,
        builder: (BuildContext bc) {
          return CupertinoAlertDialog(
            title: const Text("Wie viele Bilder sollen angezeigt werden?"),
            content: Column(
              children: [
                CupertinoTextField(
                  controller: bilderZahl,
                  placeholder: "Zahl eingeben (Standard: 36)",
                  autocorrect: false,
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            actions: [
              CupertinoDialogAction(
                  child: const Text("Spiel starten",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (_) =>
                            Game(
                              categories: categories,
                              pictureCount: int.tryParse(bilderZahl.text) ?? 40,
                            ),
                      ),
                    );
                  }),
              CupertinoDialogAction(
                child: const Text("Abbrechen"),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          );
        });
  }

  deleteConfirmation(BuildContext context) {
    showCupertinoDialog(
        context: context,
        builder: (BuildContext bc) {
          return CupertinoAlertDialog(
            title: const Text("Warnung"),
            content: const Text(
                "Du bist dabei deinen Account zu löschen. Dabei gehen alle Daten verloren"),
            actions: [
              CupertinoDialogAction(
                child: const Text("Ja, Account löschen"),
                onPressed: () => deleteAccount(context),
              ),
              CupertinoDialogAction(
                child: const Text(
                  "Abbrechen",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        });
  }

  deleteAccount(BuildContext context) async {
    context.read<UserModel>().callItADay();
    await users.doc(user.uid).delete();
    await FirebaseFirestore.instance
        .collection("gameNumbers")
        .doc(user.uid)
        .delete();
    final toDelete = [
      ...(await users.where("invites", arrayContains: user.uid).get()).docs,
      ...(await users.where("requests", arrayContains: user.uid).get()).docs,
      ...(await users.where("friends", arrayContains: user.uid).get()).docs
    ];
    for (final doc in toDelete) {
      deleteUidFromDoc(doc.id);
    }

    user.delete();
    Navigator.of(context)
        .pushReplacement(CupertinoPageRoute(builder: (_) => const Welcome()));
  }

  deleteUidFromDoc(String uid) {
    users.doc(uid).update({
      'requests': FieldValue.arrayRemove([user.uid]),
      'invites': FieldValue.arrayRemove([user.uid]),
      'friends': FieldValue.arrayRemove([user.uid])
    });
  }
}

extension on List {
  bool containsCategory(Category category) {
    for (Category e in this) {
      if (e.name == category.name) return true;
    }
    return false;
  }
}
