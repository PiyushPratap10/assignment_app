import 'package:flutter/material.dart';

class BottomNavigationProvider with ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void setIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}

class IncrementProvider with ChangeNotifier {
  int _increment = 0;

  int get increment => _increment;

  void increase() {
    _increment += 1;
    notifyListeners();
  }

  void decrease() {
    _increment -= 1;
    notifyListeners();
  }
}
