import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:who_is_it/helper.dart';
import 'package:who_is_it/model/app.dart';
import 'package:who_is_it/model/category.dart';
import 'package:who_is_it/model/picture.dart';

class Catalog extends StatefulWidget {
  const Catalog({Key? key}) : super(key: key);

  @override
  _CatalogState createState() => _CatalogState();
}

class _CatalogState extends State<Catalog> {
  final controller = PageController(keepPage: true);
  final pages = [];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        transitionBetweenRoutes: true,
        middle: Text(
          "Bilderkatalog",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),
      child: SafeArea(
        child: FutureBuilder(
            future: loadGridViews(),
            builder:
                (BuildContext context, AsyncSnapshot<List<Widget>> snapshot) {
              if (snapshot.hasError) return Text(snapshot.error!.toString());
              if (snapshot.hasData) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: PageView.builder(
                          controller: controller,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (_, index) {
                            return snapshot
                                .data![index % snapshot.data!.length];
                          },
                        ),
                      ),
                      SmoothPageIndicator(
                        controller: controller,
                        onDotClicked: (init) => controller.animateToPage(init,
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeInQuad),
                        count: snapshot.data!.length,
                        effect: JumpingDotEffect(
                          dotColor: CupertinoColors.systemGrey,
                          activeDotColor: CupertinoColors.systemPink,
                          //TODO: In ThemeData hinterlegen
                          verticalOffset: 20,
                          dotHeight: 8,
                          dotWidth: 8,
                          jumpScale: .7,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const Center(child: CupertinoActivityIndicator());
            }),
      ),
    );
  }

  Future<List<Category>> getCategories() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('global')
        .doc('categories')
        .get();
    if (snapshot.data() != null) {
      Map<String, dynamic> useData = (snapshot.data() as Map<String, dynamic>);
      List<dynamic> data = useData['names'];
      data.sort((a, b) => a['name'].toString().compareTo(b['name'].toString()));
      List<Category> categories =
          data.map((e) => Category.fromJson(e)).toList();
      return categories;
    }
    return [];
  }

  Future<List<Widget>> loadGridViews() async {
    List<Widget> result = [];
    List<Category> categories = await getCategories();

    for (Category category in categories) {
      List<Picture> pictures = await _loadFilesFromFolder(category);
      result.add(Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Text(category.name, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20, decoration: TextDecoration.underline),),
          ),
          Expanded(
            child: GridView(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: MediaQuery.of(context).size.width > 500 ? 8 : 4,
                  mainAxisSpacing: 30,
                  crossAxisSpacing: 30),
              children: pictures
                  .map((e) => GestureDetector(
                        child: Opacity(
                          child: Container(
                            child: e.image!,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: containsString(
                                            e.attributes, "Not Mental Stable")
                                        ? CupertinoColors.destructiveRed
                                        : CupertinoColors.activeGreen)),
                          ),
                          opacity: e.opacity,
                        ),
                        onTap: () async {
                          await showInfo(e, context.read<App>().brightness);
                        },
                      ))
                  .toList(),
            ),
          ),
        ],
      ));
    }
    return result;
  }

  Future<List<Picture>> _loadFilesFromFolder(Category category) async {
    try {
      List<Reference> items = [];
      ListResult listResult = await FirebaseStorage.instance
          .ref()
          .child(category.name.toLowerCase().replaceAll(" ", "-"))
          .listAll();
      items.addAll(listResult.items);

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
      return pictures;
    } on FirebaseException catch (e) {
      await FirebaseCrashlytics.instance.recordError(e.message, e.stackTrace,
          reason:
              'Catalog: Bilder laden fehlgeschlagen | Code: ${e.code} | Plugin: ${e.plugin} ');
    }

    return [];
  }

  bool containsString(List<String>? list, String string) {
    if (list == null) return false;
    for (String e in list) {
      if (e.toString() == string) return true;
    }
    return false;
  }

  showInfo(Picture picture, Brightness brightness) async {
    double height = MediaQuery.of(context).size.height / 1.9;
    double width = MediaQuery.of(context).size.width / 3;
    Padding attributes = Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: picture.attributes!
              .map((s) => Text(
                    "• $s",
                    style: TextStyle(
                        fontSize: 18,
                        color: brightness == Brightness.dark
                            ? CupertinoColors.white
                            : CupertinoColors.black),
                  ))
              .toList()),
    );

    await showCupertinoDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext bc) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                  color: context.watch<App>().brightness == Brightness.dark
                      ? Color.fromRGBO(27, 27, 27, 1.0)
                      : CupertinoColors.white,
                  borderRadius: new BorderRadius.only(
                      topLeft: const Radius.circular(20.0),
                      topRight: const Radius.circular(20.0),
                      bottomLeft: const Radius.circular(20.0),
                      bottomRight: const Radius.circular(20.0))),
              width: MediaQuery.of(context).size.width / 1.5,
              height: height,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15.0),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              "${picture.name}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                                color: brightness == Brightness.dark
                                    ? CupertinoColors.white
                                    : CupertinoColors.black,
                              ),
                            ),
                            Text(
                              "aus „${picture.category.name}“",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20,
                                  color: brightness == Brightness.dark
                                      ? CupertinoColors.white
                                      : CupertinoColors.black),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Image(
                        image: picture.image!.image,
                        height: MediaQuery.of(context).size.height / 3 - 50,
                      ),
                    ),
                    attributes,
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
            ),
          );
        });
  }
}
