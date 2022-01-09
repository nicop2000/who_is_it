import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:who_is_it/model/category.dart';
import 'package:who_is_it/model/enviroment.dart';
import 'dart:convert';
import 'dart:io';

import 'package:who_is_it/views/add_category.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseFirestore.instance.collection('global').doc('categories').update({
    'names': FieldValue.arrayUnion(
        [Category(name: "Marvel${DateTime.now().microsecond}").toJson()])
  });

  // FirebaseFirestore.instance
  //     .collection('global')
  //     .doc('categories')
  //     .snapshots()
  //     .listen((event) {
  //   if (event.data() != null) {
  //     List<Map<String, dynamic>> useData = event.data()!['names'];
  //     for (Map<String, dynamic> categoryMap in useData) {
  //       Enviroment().categories.add(Category.fromJson(categoryMap));
  //     }
  //   }
  // });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final picker = ImagePicker();
  double size = 512;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("widget.title"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CupertinoButton(
                child: Text("h"),
                onPressed: () => FirebaseFirestore.instance
                        .collection('global')
                        .doc('categories')
                        .update({
                      'names': FieldValue.arrayUnion([
                        Category(name: "Marvel${DateTime.now().microsecond}")
                            .toJson()
                      ])
                    })),

            Expanded(flex: 1, child: AddCategory()),
            const Text(
              'You have pushed the button this many times:',
            ),
            CupertinoButton(
                child: Text("Hochladen ${DateTime.now()}"),
                onPressed: () {
                  showModalBottomSheet(
                      context: context,
                      builder: (BuildContext bc) {
                        return SafeArea(
                          child: Wrap(
                            children: <Widget>[
                              ListTile(
                                  leading: const Icon(Icons.photo_library),
                                  title: const Text('Photo Library'),
                                  onTap: () async {
                                    final newImg = await _imgFromGallery();
                                    if (newImg != null) {
                                      FirebaseStorage.instance
                                          .ref()
                                          .child('picture/${DateTime.now()}')
                                          .putFile(File(newImg.path));
                                      // File f = File(newImg.path);
                                      //
                                      // FirebaseStorage.instance.ref().child('picture/${DateTime.now()}').putFile(f);
                                    }
                                    Navigator.of(context).pop();
                                  }),
                              ListTile(
                                leading: const Icon(Icons.photo_camera),
                                title: const Text('Camera'),
                                onTap: () async {
                                  final newImg = await _imgFromCamera();
                                  if (newImg != null) {
                                    FirebaseStorage.instance
                                        .ref()
                                        .child('picture/${DateTime.now()}')
                                        .putFile(File(newImg.path));
                                  }
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          ),
                        );
                      });
                }),
            Text(
              '_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: const FloatingActionButton(
        onPressed: null,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }

  // buildImage(File image) {
  //   final image = Image(image: image)
  //   return ClipOval(
  //     child: Material(
  //       color: Colors.yellow,
  //       child: Ink.image(
  //         image: image,
  //         fit: BoxFit.cover,
  //         width: 128,
  //         height: 128,
  //       ),
  //     ),
  //   );
  // }

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

  String _base64img(XFile xfile) {
    final bytes = File(xfile.path).readAsBytesSync();
    return base64Encode(bytes);
  }
}
