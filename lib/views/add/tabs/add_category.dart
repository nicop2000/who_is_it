import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:who_is_it/helper.dart';
import 'package:who_is_it/model/category.dart';

class AddCategory extends StatefulWidget {
  const AddCategory({Key? key}) : super(key: key);

  @override
  _AddCategoryState createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> {
  TextEditingController categoryNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Helper.getHeadline("Neues Kategorie hinzufügen")),
                  CupertinoTextField(
                    controller: categoryNameController,
                    onChanged: (changed) => setState(() {}),
                    clearButtonMode: OverlayVisibilityMode.editing,
                    autocorrect: false,
                    textCapitalization: TextCapitalization.none,
                    placeholder: "Kategorie eingeben",
                    textAlign: TextAlign.center,
                    padding: const EdgeInsets.all(10.0),
                  ),
                  CupertinoButton(
                      child: Text(
                          'Kategorie ${categoryNameController.text} hinzufügen'),
                      onPressed: () => addCategory(categoryNameController.text))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  addCategory(String name) {
    FirebaseFirestore.instance.collection('global').doc('categories').update({
      'names': FieldValue.arrayUnion([Category(name: name).toJson()])
    }).then((value) async {
      await showCupertinoDialog(
          context: context,
          builder: (BuildContext bc) {
            return CupertinoAlertDialog(
              title: const Text("Erfolgreich"),
              content: Column(
                children: [
                  Text(
                      "Kategorie ${categoryNameController.text} wurde erfolgreich hinzugefügt"),
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
      categoryNameController.text = "";
    }).onError((error, stackTrace) async {
      await FirebaseCrashlytics.instance.recordError(
          error,
          stackTrace,
          reason: 'Kategorie hinzufügen fehlgeschlagen'
      );
      await showCupertinoDialog(
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
                  child: const Text("Ok"),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            );
          });
    });
    setState(() {

    });
  }

  List<Category> mapToCategoryList(List<dynamic> listToSort) {
    List<Category> toReturn =
        listToSort.map((e) => Category.fromJson(e)).toList();
    toReturn.sort((a, b) => a.name.compareTo(b.name));
    return toReturn;
  }


}
