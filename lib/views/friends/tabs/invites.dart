import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InvitesPage extends StatefulWidget {
  const InvitesPage({Key? key}) : super(key: key);

  @override
  State<InvitesPage> createState() => _InvitesPageState();
}

class _InvitesPageState extends State<InvitesPage> {
  List<QueryDocumentSnapshot<Object?>> _items = [];
  String uid = FirebaseAuth.instance.currentUser!.uid;
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
          margin: const EdgeInsets.all(10.0),
          child: StreamBuilder(
            stream: users.where("requests", arrayContains: uid).snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasData) {
                _items = snapshot.data!.docs;
                if (_items.isEmpty) {
                  return const Center(
                    child: Text("Momentan hast du keine Freundschaftsanfragen"),
                  );
                }
                return ListView(
                  children: _items.map((e) => _buildItem(e)).toList(),
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Center(
                      child: SizedBox(
                          height: 50,
                          width: 50,
                          child: CupertinoActivityIndicator()),
                    ),
                  ],
                );
              }
            },
          )),
    );
  }

  Widget _buildItem(QueryDocumentSnapshot<Object?> item) {
    return Card(
      margin: const EdgeInsets.all(20.0),
      elevation: 5.0,
      child: Padding(
        padding: const EdgeInsets.only(
            top: 2.0, bottom: 2.0, right: 10.0, left: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(item.get("name")),
            const Spacer(),
            IconButton(
              icon: const Icon(
                CupertinoIcons.add_circled_solid,
                color: CupertinoColors.activeGreen,
              ),
              onPressed: () async {
                WriteBatch writeBatch = FirebaseFirestore.instance.batch();
                users.doc(item.id).update({
                  'invites': FieldValue.arrayRemove([uid]),
                  'requests': FieldValue.arrayRemove([uid]),
                  'friends': FieldValue.arrayUnion([uid])
                });
                users.doc(uid).update({
                  'requests': FieldValue.arrayRemove([item.id]),
                  'invites': FieldValue.arrayRemove([item.id]),
                  'friends': FieldValue.arrayUnion([item.id])
                }).then((value) => writeBatch.commit());

                showCupertinoDialog(
                    context: context,
                    builder: (BuildContext bc) {
                      return CupertinoAlertDialog(
                        title: const Text("Erfolg"),
                        content: Column(
                          children: [
                            Text(
                                "${item.get("name")} gehört jetzt zu deinen Freunden"),
                          ],
                        ),
                        actions: [
                          CupertinoDialogAction(
                            child: const Text("OK"),
                            onPressed: () => Navigator.of(context).pop(),
                          )
                        ],
                      );
                    });

                // _deleteItem(index);
              },
            ),
            IconButton(
              icon: const Icon(
                CupertinoIcons.clear_circled_solid,
                color: CupertinoColors.systemRed,
              ),
              onPressed: () async {
                users.doc(item.id).update({
                  'requests': FieldValue.arrayRemove([uid]),
                });
                users.doc(uid).update({
                  'invites': FieldValue.arrayRemove([item.id]),
                });
                showCupertinoDialog(
                    barrierDismissible: true,
                    context: context,
                    builder: (BuildContext bc) {
                      return CupertinoAlertDialog(
                        title: const Text("Erfolg"),
                        content: Column(
                          children: [
                            Text(
                                "Die Anfrage von ${item.get("name")} wurde abgelehnt"),
                          ],
                        ),
                        actions: [
                          CupertinoDialogAction(
                            child: const Text("OK"),
                            onPressed: () => Navigator.of(context).pop(),
                          )
                        ],
                      );
                    });
              },
            ),
          ],
        ),
      ),
    );
  }
}
