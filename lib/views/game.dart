// ignore_for_file: implementation_imports
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:who_is_it/model/app.dart';
import 'package:who_is_it/model/category.dart';
import 'package:who_is_it/model/opponent.dart';
import 'package:who_is_it/model/picture.dart';

class Game extends StatefulWidget {
  const Game({Key? key, required this.categories, required this.pictureCount})
      : super(key: key);
  final List<Category> categories;
  final int pictureCount;

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
            future: _loadFilesFromFolder(widget.categories),
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
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount:
                                          MediaQuery.of(context).size.width >
                                                  500
                                              ? 8
                                              : 4,
                                      mainAxisSpacing: 30,
                                      crossAxisSpacing: 30),
                              children: snapshot.data!
                                  .map((e) => GestureDetector(
                                        child: Opacity(
                                          child: Container(
                                            child: e.image!,
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: containsString(
                                                            e.attributes,
                                                            "Not Mental Stable")
                                                        ? CupertinoColors
                                                            .destructiveRed
                                                        : CupertinoColors
                                                            .activeGreen)),
                                          ),
                                          opacity: e.opacity,
                                        ),
                                        onLongPress: () async {
                                          await showInfo(e, context.read<App>().brightness);
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
                                      .doc(context.read<Opponent>().uid)
                                      .snapshots(),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<
                                              DocumentSnapshot<
                                                  Map<String, dynamic>>>
                                          snapshot) {
                                    if (snapshot.hasData) {
                                      return FutureBuilder(
                                          future: getOpponentPicture(snapshot
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
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 11.0),
                                                  child: GestureDetector(
                                                    child: Opacity(
                                                      child: Container(
                                                        child: picture.image!,
                                                        decoration: BoxDecoration(
                                                            border: Border.all(
                                                                color: containsString(
                                                                        picture
                                                                            .attributes,
                                                                        "Not Mental Stable")
                                                                    ? CupertinoColors
                                                                        .destructiveRed
                                                                    : CupertinoColors
                                                                        .activeGreen)),
                                                      ),
                                                      opacity: picture.opacity,
                                                    ),
                                                    onLongPress: () async {
                                                      await showInfo(picture, context.read<App>().brightness);
                                                    },
                                                    onTap: () {
                                                      opacityStateOponent(() {
                                                        picture.changeOpacity();
                                                      });
                                                    },
                                                  ),
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
                                        CupertinoActivityIndicator(),
                                      ],
                                    );
                                  }),
                              Column(
                                children: [
                                  CupertinoButton(
                                      child: const Text("Neu senden"),
                                      onPressed: sendNumber),
                                  CupertinoButton(
                                      child: const Text("Alle anzeigen"),
                                      onPressed: () {
                                        for (Picture picture in backup) {
                                          picture.opacity = 1.0;
                                          opacityState(() {});
                                        }
                                      }),
                                ],
                              ),
                              Column(
                                children: [
                                  CupertinoButton(
                                    child: const Text("Neue Runde"),
                                    onPressed: () => Navigator.pushReplacement(
                                      context,
                                      CupertinoPageRoute(
                                          builder: (_) => Game(
                                                categories: widget.categories,
                                                pictureCount:
                                                    widget.pictureCount,
                                              )),
                                    ),
                                  ),
                                ],
                              )
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

  Future<Picture?> getOpponentPicture(int pictureNumber) async {
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
              attributes: picture.attributes,
              name: picture.name,
              image: image);
          return pic2;
        }
      }
    }
    return null;
  }

  showInfo(Picture picture, Brightness brightness) async {
    double height = MediaQuery.of(context).size.height / 2;
    double width = MediaQuery.of(context).size.width / 3;
    List<Widget> attributes = [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        child: Row(
          children: [
            Spacer(),
            Column(
              children: [
                Text(
                  "${picture.name}",
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: brightness == Brightness.dark ? CupertinoColors.white : CupertinoColors.black,),
                ),
                Text(
                  "aus „${picture.category.name}“",
                  style:
                      TextStyle(fontWeight: FontWeight.w600, fontSize: 20, color: brightness == Brightness.dark ? CupertinoColors.white : CupertinoColors.black),
                ),
              ],
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Image(image: picture.image!.image, height: height - 200, width: width - 100,),
            ),
            Spacer(),

          ],
        ),
      )
    ];
    if (picture.attributes != null) {
      attributes.addAll(picture.attributes!
          .map((s) => Text(
                "• $s",
                style: TextStyle(fontSize: 18, color: brightness == Brightness.dark ? CupertinoColors.white : CupertinoColors.black),
              ))
          .toList());
    }

    await showCupertinoDialog(
      barrierDismissible: true,
        context: context,
        builder: (BuildContext bc) {
          return Dialog(
            child: Container(
              color: context.watch<App>().brightness == Brightness.dark ? Color.fromRGBO(27, 27, 27, 1.0) : null,
              width: MediaQuery.of(context).size.width / 2,
              height: height,
              child: Column(
                children: [
                  Column(
                    children: attributes,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: CupertinoDialogAction(
                      child: const Text("OK"),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Future<List<Picture>> _loadFilesFromFolder(List<Category> categories) async {
    if (backup.isNotEmpty) return backup;
    int pictureCount = widget.pictureCount;
    try {
      List<Reference> items = [];
      for (Category category in categories) {
        ListResult listResult = await FirebaseStorage.instance
            .ref()
            .child(category.name.toLowerCase().replaceAll(" ", "-"))
            .listAll();
        items.addAll(listResult.items);
      }

      items.shuffle(Random());
      items.shuffle(Random());
      if (widget.pictureCount >= items.length) {
        pictureCount = items.length;
      }
      items.removeRange(pictureCount, items.length);

      List<Picture> pictures = await Future.wait(items.map((ref) async {
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
                attributes: picture.attributes,
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
      await FirebaseCrashlytics.instance.recordError(e.message, e.stackTrace,
          reason:
              'Game: Bilder laden fehlgeschlagen | Code: ${e.code} | Plugin: ${e.plugin} ');
    }
    return [];
  }

  Future<void> sendNumber() async {
    await FirebaseFirestore.instance
        .collection('gameNumbers')
        .doc(FirebaseAuth.instance.currentUser!.uid) //eigene UID
        .set({
      "picture": int.parse(backup[Random().nextInt(backup.length - 1)].filename)
    });
  }

  bool containsString(List<String>? list, String string) {
    if (list == null) return false;
    for (String e in list) {
      if (e.toString() == string) return true;
    }
    return false;
  }
}
