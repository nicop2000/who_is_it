import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class AddCategory extends StatefulWidget {
  const AddCategory({Key? key}) : super(key: key);

  @override
  _AddCategoryState createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> {
  TextEditingController categoryNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(15.0),
            child: Text(
              "Neue Kategorie hinzufügen",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          CupertinoTextField(
            controller: categoryNameController,
            onChanged: (changed) => setState(() {}),
            clearButtonMode: OverlayVisibilityMode.always,
            textAlign: TextAlign.center,
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
                  List<dynamic> useData = snapshot.data!.data()!['names'];
                  return Expanded(
                      flex: 1,
                      child: ListView(
                        children: useData
                            .map((e) => /*Dismissible(
                              key: Key(Category.fromJson(e).name),
                              onDismissed: (direction) {
                                FirebaseFirestore.instance
                                    .collection('global')
                                    .doc('categories')
                                    .update({
                                  'names': FieldValue.arrayRemove([e])
                                });

                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text(
                                        '${Category.fromJson(e).name} gelöscht')));
                              },
                              // Show a red background as the item is swiped away.
                              background: Container(color: Colors.red),
                              child: */Category.fromJson(e).toWidget())/*)*/
                            .toList(),
                      ));
                }
                return const Expanded(flex: 1, child: CircularProgressIndicator());
              }),
          CupertinoPicker(itemExtent: 30, onSelectedItemChanged: () {}, children: )
          CupertinoButton(
              child:
                  Text('Kategorie ${categoryNameController.text} hinzufügen'),
              onPressed: addCategory)
        ],
      ),
    );
  }

  addCategory() {}
}
