import 'package:flutter/cupertino.dart';

class Opponent extends ChangeNotifier {

  String uid;
  String name;
  Opponent(this.uid, this.name);

  void setData({required String uid, required String name}) {
    this.uid = uid;
    this.name = name;
    notifyListeners();
  }


  void reset() {
    uid = "";
    name = "";
    notifyListeners();
  }
}