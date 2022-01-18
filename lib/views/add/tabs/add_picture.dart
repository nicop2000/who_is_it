import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:who_is_it/helper.dart';
import 'package:who_is_it/model/category.dart';
import 'package:who_is_it/model/picture.dart';

class AddPicture extends StatefulWidget {
  const AddPicture({Key? key}) : super(key: key);

  @override
  _AddPictureState createState() => _AddPictureState();
}

class _AddPictureState extends State<AddPicture> {
  Category? categoryAdd;
  Picture? picture;
  File? image;
  final picker = ImagePicker();
  double size = 512;
  TextEditingController nameController = TextEditingController();
  TextEditingController attributesController = TextEditingController();
  Set<String> attributes = {};

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Helper.getHeadline("Neues Bild hinzufügen"),
              ),
              CupertinoButton(
                  child: const Text("Bild auswählen"),
                  onPressed: () {
                    showCupertinoDialog(
                        context: context,
                        builder: (BuildContext bc) {
                          return CupertinoAlertDialog(
                            title: const Text("Bild auswählen"),
                            content: Column(
                              children: const [
                                Text(
                                    "Aus welcher Quelle soll das Bild importiert werden?"),
                              ],
                            ),
                            actions: <Widget>[
                              CupertinoDialogAction(
                                child: const Text("Bild aus Galerie auswählen"),
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                  final newImg = await _imgFromGallery();
                                  if (newImg != null) {
                                    setState(() {
                                      image = File(newImg.path);
                                    });
                                  }
                                },
                              ),
                              CupertinoDialogAction(
                                child: const Text("Bild von Kamera auswählen"),
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                  final newImg = await _imgFromCamera();
                                  if (newImg != null) {
                                    setState(() {
                                      image = File(newImg.path);
                                    });
                                  }
                                },
                              ),
                            ],
                          );
                        });
                  }),
              if (image != null)
                Image.file(
                  image!,
                  height: 200,
                ),
              StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('global')
                      .doc('categories')
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                          snapshot) {
                    if (snapshot.hasData) {
                      return Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          children: [
                            CupertinoButton(
                                child: const Text("Kategorie auswählen"),
                                onPressed: () {
                                  showCupertinoModalPopup<void>(
                                      context: context,
                                      builder: (BuildContext context) {
                                        List<dynamic> useData =
                                            snapshot.data!.data()!['names'];

                                        return _buildBottomPicker(
                                            _buildCupertinoPicker(
                                                mapToCategoryList(useData)));
                                      });
                                }),
                            if (categoryAdd != null)
                              Text("Ausgewählte Kategorie ${categoryAdd!.name}")
                          ],
                        ),
                      );
                    }
                    return const CupertinoActivityIndicator();
                  }),
              CupertinoTextField(
                controller: nameController,
                placeholder: "Namen eingeben",
                onChanged: (changed) => setState(() {}),
                clearButtonMode: OverlayVisibilityMode.editing,
                textAlign: TextAlign.center,
                padding: const EdgeInsets.all(10.0),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: CupertinoTextField(
                    controller: attributesController,
                    autocorrect: false,
                    textCapitalization: TextCapitalization.none,
                    onChanged: (value) => setState(() {}),
                    clearButtonMode: OverlayVisibilityMode.editing,
                    textAlign: TextAlign.center,
                    padding: const EdgeInsets.all(10.0),
                    onSubmitted: (value) => addAttribute(value),
                    onEditingComplete: () {},
                    placeholder: "Eigenschaft eingeben",
                    textInputAction: Platform.isAndroid
                        ? TextInputAction.go
                        : TextInputAction.done),
              ),
              CupertinoButton(
                  child: const Text("Attribut hinzufügen"),
                  onPressed: attributesController.text == ""
                      ? null
                      : () => addAttribute(attributesController.text)),
              Column(
                children: attributes
                    .map(
                      (e) => Row(
                        children: [
                          Tooltip(
                            message: "Eigenschaft löschen",
                            child: CupertinoButton(
                              child: const Icon(
                                CupertinoIcons.clear_circled_solid,
                                color: CupertinoColors.systemRed,
                              ),
                              onPressed: () => setState(() {
                                attributes.remove(e);
                              }),
                            ),
                          ),
                          Text(e),
                        ],
                      ),
                    )
                    .toList(),
              ),
              CupertinoButton(
                  child: Text(
                      'Bild ${nameController.text} zur Kategorie ${categoryAdd != null ? categoryAdd!.name : ""} hinzufügen'),
                  onPressed: addPicture),
            ],
          ),
        ),
      ),
    );
  }

  addAttribute(String value) {
    if (value.trim().isNotEmpty) {
      setState(() {
        attributes.add(value);
      });
    }
    attributesController.text = "";
  }

  addPicture() async {
    if (image != null && categoryAdd != null) {
      Picture picture = Picture(
          name: nameController.text,
          category: categoryAdd!,
          filename: "-1");
      picture.attributes = attributes.toList();
      DocumentSnapshot<Map<String, dynamic>> data = await FirebaseFirestore.instance.collection('global').doc('names').get();
      if (data.data() != null) {

        List<dynamic> picNames = data.data()!['files'];
        for (Map<String, dynamic> map in picNames) {
          if (normString(nameController.text) == normString(map.values.first['name'])) {
            await showCupertinoDialog(
                context: context,
                builder: (BuildContext bc) {
                  return CupertinoAlertDialog(
                    title: const Text("Da war jemand schneller"),
                    content: Column(
                      children: [
                        Text(
                            "Es gibt bereits ein Bild mit dem Namen ${nameController.text} in der Kategorie ${categoryAdd!.name}"),
                      ],
                    ),
                    actions: <Widget>[
                      CupertinoDialogAction(
                        child: const Text("OK"),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  );
                });
            return;
          }
        }
      }
      FirebaseStorage.instance
          .ref()
          .child(picture.getLink())
          .getDownloadURL()
          .then((value) async {
        await showCupertinoDialog(
            context: context,
            builder: (BuildContext bc) {
              return CupertinoAlertDialog(
                title: const Text("Hoppla"),
                content: Column(
                  children: const [
                    Text(
                        "Da ist ein Fehler aufgetreten. Bitte versuche es nochmal"),
                  ],
                ),
                actions: <Widget>[
                  CupertinoDialogAction(
                    child: const Text("OK"),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              );
            });
      }).onError((error, stackTrace) async {
        int nextID = -1;
        DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
            .collection('global')
            .doc('lastID')
            .get();
        if (documentSnapshot.data() != null) {
          nextID = int.parse(
                  (documentSnapshot.data() as Map<String, dynamic>)['id']
                      .toString()) +
              1;
          picture.filename = (nextID).toString();
        }
        FirebaseStorage.instance
            .ref()
            .child(picture.getLink())
            .putFile(image!)
            .then((value) async {
          WriteBatch writeBatch = FirebaseFirestore.instance.batch();

          await FirebaseFirestore.instance
              .collection('global')
              .doc('names')
              .update({
            'files': FieldValue.arrayUnion([
              {nextID.toString(): picture.toJson()}
            ])
          });
          await FirebaseFirestore.instance
              .collection('global')
              .doc('lastID')
              .set({'id': nextID}).then((value) => writeBatch.commit());

          await showCupertinoDialog(
              context: context,
              builder: (BuildContext bc) {
                return CupertinoAlertDialog(
                  title: const Text("Erfolgreich"),
                  content: Column(
                    children: [
                      Text(
                          "Das Bild ${nameController.text} wurde erfolgreich hinzugefügt"),
                    ],
                  ),
                  actions: <Widget>[
                    CupertinoDialogAction(
                      child: const Text("OK"),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                );
              });
          setState(() {
            nameController.text = "";
            image = null;
            categoryAdd = null;
            attributes = {};
          });
        }).onError((error, stackTrace) async {
          await FirebaseCrashlytics.instance.recordError(
              error,
              stackTrace,
              reason: 'Namen der Dateien abrufen fehlgeschlagen'
          );
          showCupertinoDialog(
              context: context,
              builder: (BuildContext bc) {
                return CupertinoAlertDialog(
                  title: const Text("Fehler"),
                  content: Column(
                    children: const [
                      Text("Das hat nicht geklappt. Bitte probiere es nochmal"),
                    ],
                  ),
                  actions: <Widget>[
                    CupertinoDialogAction(
                      child: const Text("OK"),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                );
              });
        });
      });
    }
  }

  List<Category> mapToCategoryList(List<dynamic> listToSort) {
    List<Category> toReturn =
        listToSort.map((e) => Category.fromJson(e)).toList();
    toReturn.sort((a, b) => a.name.compareTo(b.name));
    return toReturn;
  }

  Future<XFile?> _imgFromCamera() async {
    final imageFile = await picker.pickImage(
        source: ImageSource.camera, maxHeight: size, maxWidth: size);
    return imageFile;
  }

  Future<XFile?> _imgFromGallery() async {
    final imageFile = await picker.pickImage(
        source: ImageSource.gallery, maxHeight: size, maxWidth: size);
    return imageFile;
  }

// String _base64img(XFile xfile) {
//   final bytes = File(xfile.path).readAsBytesSync();
//   return base64Encode(bytes);
// }

  Widget _buildCupertinoPicker(List<Category> items) {
    categoryAdd = items.first;
    return CupertinoPicker(
      // magnification: 1.5,
      backgroundColor: CupertinoColors.white,
      itemExtent: 30,
      //height of each item
      // squeeze: 0.5,
      magnification: 1.2,

      looping: false,
      children: items
          .map((item) => Center(
                child: Text(
                  item.name,
                  style: const TextStyle(fontSize: 24),
                ),
              ))
          .toList(),

      onSelectedItemChanged: (index) {
        categoryAdd = items[index];
      },
    );
  }

  Widget _buildBottomPicker(Widget picker) {
    return Container(
      color: CupertinoColors.white,
      height: MediaQuery.of(context).size.height / 3,
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              CupertinoButton(
                child: const Text('Abbrechen'),
                onPressed: () {
                  setState(() {
                    categoryAdd = null;
                  });
                  Navigator.of(context).pop();
                },
              ),
              CupertinoButton(
                child: const Text('Fertig'),
                onPressed: () {
                  setState(() {});
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          const Divider(
            height: 0,
            thickness: 1,
          ),
          const Spacer(),
          Expanded(flex: 1, child: picker),
          const Spacer()
        ],
      ),
    );
  }
  String normString(String toNorm) => toNorm.trim().toLowerCase().replaceAll(" ", "").replaceAll("\n", "").replaceAll("_", "").replaceAll("-", "");
}
