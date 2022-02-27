import 'package:flutter/cupertino.dart';

class App extends ChangeNotifier {

  Brightness brightness = Brightness.light;

  void setBrightness(Brightness brightness) {
    brightness = brightness;
    notifyListeners();
  }
}