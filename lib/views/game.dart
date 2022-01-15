import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:who_is_it/model/category.dart';
import 'package:who_is_it/model/picture.dart';

class Game extends StatefulWidget {
  const Game(
      {Key? key,
      required this.category,
      this.pictureCount = 36,
      required this.uidFriend})
      : super(key: key);
  final Category category;
  final int pictureCount;
  final String uidFriend; //TODO: Friend model anlegen

  @override
  _GameState createState() => _GameState();
}

class _GameState extends State<Game> {
  List<Picture> backup = [];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: FutureBuilder(
            future: _loadFilesFromFolder(widget.category.name),
            builder:
                (BuildContext context, AsyncSnapshot<List<Picture>> snapshot) {
              if (snapshot.hasError) return Text(snapshot.error!.toString());
              if (snapshot.hasData) {
                return Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: StatefulBuilder(
                    builder: (BuildContext context, StateSetter opacityState) {
                      return Column(
                        children: [
                          Expanded(
                            child: GridView(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      mainAxisSpacing: 30,
                                      crossAxisSpacing: 30),
                              children: snapshot.data!
                                  .map((e) => GestureDetector(
                                        child: Opacity(
                                          child: e.image!,
                                          opacity: e.opacity,
                                        ),
                                        onLongPress: () async {
                                          List<Widget> attributes = [
                                            Text(
                                              e.name,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            )
                                          ];
                                          if (e.attributes != null) {
                                            attributes.addAll(e.attributes!
                                                .map((s) => Text(s))
                                                .toList());
                                          }
                                          await showCupertinoDialog(
                                              context: context,
                                              builder: (BuildContext bc) {
                                                return CupertinoAlertDialog(
                                                  title: const Text(
                                                      "Eigenschaften"),
                                                  content: Column(
                                                    children: attributes,
                                                  ),
                                                  actions: <Widget>[
                                                    CupertinoDialogAction(
                                                      child: const Text("Ok"),
                                                      onPressed: () =>
                                                          Navigator.of(context)
                                                              .pop(),
                                                    ),
                                                  ],
                                                );
                                              });
                                        },
                                        onTap: () {
                                          opacityState(() {
                                            e.changeOpacity();
                                          });
                                        },
                                      ))
                                  .toList(),
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              StreamBuilder(
                                  stream: FirebaseFirestore.instance
                                      .collection('gameNumbers')
                                      .doc(widget.uidFriend) //TODO: Überprüfen
                                      .snapshots(),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<
                                              DocumentSnapshot<
                                                  Map<String, dynamic>>>
                                          snapshot) {
                                    if (snapshot.hasData) {
                                      return FutureBuilder(
                                          future: getOponentPicture(snapshot
                                              .data!
                                              .data()!['picture']),
                                          builder: (BuildContext context,
                                              AsyncSnapshot<Picture?>
                                                  snapshot) {
                                            if (snapshot.hasData) {
                                              Picture picture = snapshot.data!;
                                              return StatefulBuilder(builder:
                                                  (BuildContext context,
                                                      StateSetter
                                                          opacityStateOponent) {
                                                return GestureDetector(
                                                  child: Opacity(
                                                    child: picture.image!,
                                                    opacity: picture.opacity,
                                                  ),
                                                  onLongPress: () async {
                                                    List<Widget> attributes = [
                                                      Text(
                                                        picture.name,
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      )
                                                    ];
                                                    if (picture.attributes !=
                                                        null) {
                                                      attributes.addAll(picture
                                                          .attributes!
                                                          .map((s) => Text(s))
                                                          .toList());
                                                    }
                                                    await showCupertinoDialog(
                                                        context: context,
                                                        builder:
                                                            (BuildContext bc) {
                                                          return CupertinoAlertDialog(
                                                            title: const Text(
                                                                "Eigenschaften"),
                                                            content: Column(
                                                              children:
                                                                  attributes,
                                                            ),
                                                            actions: <Widget>[
                                                              CupertinoDialogAction(
                                                                child:
                                                                    const Text(
                                                                        "OK"),
                                                                onPressed: () =>
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop(),
                                                              ),
                                                            ],
                                                          );
                                                        });
                                                  },
                                                  onTap: () {
                                                    opacityStateOponent(() {
                                                      picture.changeOpacity();
                                                    });
                                                  },
                                                );
                                              });
                                            }
                                            if (snapshot.hasError) {
                                              return const Text(
                                                  "Ein Fehler ist aufgetreten bei Bild holen");
                                            }
                                            return const CupertinoActivityIndicator();
                                          });
                                    }
                                    if (snapshot.hasError) {
                                      return const Text(
                                          "Ein Fehler ist aufgetreten bei Nummer holen");
                                    }
                                    return Column(
                                      children: const [
                                        Text("Nummer"),
                                        CupertinoActivityIndicator(),
                                      ],
                                    );
                                  }),
                              CupertinoButton(
                                  child: const Text("Neu senden"),
                                  onPressed: sendNumber),
                              CupertinoButton(
                                  child: const Text("Alle anzeigen"),
                                  onPressed: () {
                                    backup.forEach((element) {
                                      element.opacity = 1.0;
                                      opacityState(() {});
                                    });
                                  }),
                            ],
                          )
                        ],
                      );
                    },
                  ),
                );
              }
              return const CupertinoActivityIndicator();
            }),
      ),
    );
  }

  Future<Picture?> getOponentPicture(int pictureNumber) async {
    DocumentSnapshot<Map<String, dynamic>> picData = await FirebaseFirestore
        .instance
        .collection('global')
        .doc('names')
        .get();
    if (picData.data() != null) {
      List<dynamic> picsRaw = picData.data()!['files'];
      for (Map<String, dynamic> map in picsRaw) {
        if (int.parse(map.keys.first) == pictureNumber) {
          Picture picture = Picture.fromJson(map.values.first);
          String b = await FirebaseStorage.instance
              .ref()
              .child(picture.getLink())
              .getDownloadURL();
          Image image = Image.network(
            b,
            height: 60,
            width: 60,
            fit: BoxFit.scaleDown,
          );
          Picture pic2 = Picture(
              filename: picture.filename,
              category: picture.category,
              name: picture.name,
              image: image);
          return pic2;
        }
      }
    }
    return null;
  }

  Future<List<Picture>> _loadFilesFromFolder(String folder) async {
    int pictureCount = widget.pictureCount;
    try {
      ListResult fileList = await FirebaseStorage.instance
          .ref()
          .child(folder.toLowerCase())
          .listAll();
      fileList.items.shuffle();
      fileList.items.shuffle();
      if (widget.pictureCount >= fileList.items.length) {
        pictureCount = fileList.items.length - 1;
      }
      fileList.items.removeRange(pictureCount, fileList.items.length - 1);

      List<Picture> pictures =
          await Future.wait(fileList.items.map((ref) async {
        int filenameID = int.parse(ref.fullPath.split("/")[1]);
        DocumentSnapshot<Map<String, dynamic>> picData = await FirebaseFirestore
            .instance
            .collection('global')
            .doc('names')
            .get();
        if (picData.data() != null) {
          List<dynamic> picsRaw = picData.data()!['files'];
          for (Map<String, dynamic> map in picsRaw) {
            if (int.parse(map.keys.first) == filenameID) {
              Picture picture = Picture.fromJson(map.values.first);
              return Picture(
                category: picture.category,
                filename: picture.filename,
                name: picture.name,
                image: Image.network(
                  await ref.getDownloadURL(),
                  height: 30,
                  width: 30,
                  fit: BoxFit.scaleDown,
                ),
                opacity: 1.0,
              );
            }
          }
        }
        return Picture(
          category: Category(name: ref.fullPath.split("/")[0]),
          filename: ref.fullPath.split("/")[1],
          name: "",
          image: Image.network(
            await ref.getDownloadURL(),
            height: 30,
            width: 30,
            fit: BoxFit.scaleDown,
          ),
          opacity: 1.0,
        );
      }));

      backup = pictures;
      await sendNumber();

      return pictures;
    } on FirebaseException catch (e) {
      print(e.code);
      print(e.message);
      print(e.stackTrace);
      print(e.plugin);
      //TODO: Crashlytics
      // await FirebaseCrashlytics.instance.recordError(
      //     e.message,
      //     e.stackTrace,
      //     reason: 'Dateipfade der Bilder von FirebaseStorage abrufen'
      // );
    }
    return [];
  }

  Future<void> sendNumber() async {
    await FirebaseFirestore.instance
        .collection('gameNumbers')
        .doc(FirebaseAuth.instance.currentUser!.uid) //TODO: eigene UID rein
        .set({
      "picture": int.parse(backup[Random().nextInt(backup.length - 1)].filename)
    });
  }
}
