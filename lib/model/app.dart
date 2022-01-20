import 'package:flutter/cupertino.dart';

class App extends ChangeNotifier {

  Brightness _brightness = Brightness.dark;

  void setBrightness(Brightness brightness) {
    _brightness = brightness;
    notifyListeners();
  }

  Brightness get brightness => _brightness;
}