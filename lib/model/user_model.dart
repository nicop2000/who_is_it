import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends ChangeNotifier {
  String name;
  List<String> requests;
  List<String> invites;
  List<String> friends;
  @JsonKey(ignore: true)
  StreamSubscription? userDataStream;

  UserModel(
      this.name, this.requests, this.invites, this.friends);

  setUserModel(UserModel? newModel) {
    if (newModel != null) {
      name = newModel.name;
      requests = newModel.requests;
      invites = newModel.invites;
      friends = newModel.friends;
      notifyListeners();
    }
  }

  changeName(String name) {
    this.name = name;
    notifyListeners();
  }

  lookAfterYourself() {
    userDataStream = FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser!.uid).snapshots().listen((event) {
      UserModel userModel =  UserModel.fromJson(event.data() as Map<String, dynamic>);
      setUserModel(userModel);
    });
  }

  callItADay() {
    if(userDataStream != null) {
      userDataStream!.cancel();
    }
    name = "";
    requests.clear();
    invites.clear();
    friends.clear();
  }



  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
