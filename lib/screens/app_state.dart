import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  bool _isQrScanned = false;

  bool get isQrScanned => _isQrScanned;

  void setQrScanned(bool value) {
    _isQrScanned = value;
    notifyListeners();
  }
}