import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:who_is_it/model/user_model.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String uid = FirebaseAuth.instance.currentUser!.uid;
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  List<QueryDocumentSnapshot> friendsSuggestions = [];
  String lastSearch = "";

  getSuggestion(String? text) {
    
    text ??= lastSearch;
    users
        .where("name", isGreaterThanOrEqualTo: text)
        .where("name", isLessThanOrEqualTo: "$text\uf7ff")
        .get()
        .then((query) {
      friendsSuggestions = [];
      if (text!.isNotEmpty) {
        friendsSuggestions = query.docs.where((doc) => doc.id != uid).toList();
      }
      setState(() => lastSearch = text!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: searchBar(),
              ),
              resultSet(),
            ],
          ),
        ),
      ),
    );
  }

  Widget searchBar() {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Flexible(
            fit: FlexFit.loose,
            child: Container(
              margin: const EdgeInsets.only(left: 10),
              child: CupertinoTextField(
                placeholder: "Name eingeben",
                onChanged: getSuggestion,
                maxLines: 1,
                clearButtonMode: OverlayVisibilityMode.always,
                suffix: const Icon(CupertinoIcons.search),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget resultSet() {
    if (friendsSuggestions.isNotEmpty) {
      return Column(
        children: friendsSuggestions
            .map(
              (doc) => Card(
                margin: const EdgeInsets.all(20.0),
                elevation: 5.0,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 10.0, right: 10.0, left: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                    Text(doc.get("name")),
                    StatefulBuilder(
                      builder: (BuildContext context, StateSetter stateSetter) {
                        UserModel user = context.read<UserModel>();
                        bool isInvited = user.requests.contains(doc.id);
                        bool isFriend = user.friends.contains(doc.id);
                        return getButton(isFriend: isFriend, isInvited: isInvited, snapshot: doc);
                      },
                    ),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      );
    } else {
      return Text("");
    }
  }

  Widget getButton({required bool isFriend, required bool isInvited, required QueryDocumentSnapshot snapshot}) {
    if (isFriend) {
      return const Icon(CupertinoIcons.check_mark_circled_solid, color: CupertinoColors.systemGrey,);

    } else if (isInvited) {
      return CupertinoButton(
        child: const Icon(CupertinoIcons.clear_circled_solid, color: CupertinoColors.systemRed,), //TODO: Icon?
        onPressed: () {
          users.doc(snapshot.id).update({
            'invites': FieldValue.arrayRemove([uid])
          });
          users.doc(uid).update({
            'requests': FieldValue.arrayRemove([snapshot.id])
          });
          getSuggestion(null);
        },
      );
    } else {
      return CupertinoButton(
        child: const Icon(CupertinoIcons.add_circled_solid, color: CupertinoColors.activeGreen,),
        onPressed: () async {
          await users.doc(snapshot.id).update({
            'invites': FieldValue.arrayUnion([uid])
          });
          await users.doc(uid).update({
            'requests': FieldValue.arrayUnion([snapshot.id])
          });
          var ownModelRaw = await users.doc(uid).get();
          UserModel ownUserModel =  UserModel.fromJson(ownModelRaw.data() as Map<String, dynamic>);
          if (ownUserModel.invites.contains(snapshot.id) && ownUserModel.requests.contains(snapshot.id)) {
            WriteBatch writeBatch = FirebaseFirestore.instance.batch();
            users.doc(snapshot.id).update({
              'invites': FieldValue.arrayRemove([uid]),
              'requests': FieldValue.arrayRemove([uid]),
              'friends': FieldValue.arrayUnion([uid])
            });
            users.doc(uid).update({
              'requests': FieldValue.arrayRemove([snapshot.id]),
              'invites': FieldValue.arrayRemove([snapshot.id]),
              'friends': FieldValue.arrayUnion([snapshot.id])
            }).then((value) => writeBatch.commit());
          }
          getSuggestion(null);
        },
      );
    }
  }
}
