import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  bool _isQrScanned = false;
  String _depotName = '';
  String _message = '';

  bool get isQrScanned => _isQrScanned;
  String get depotName => _depotName;
  String get message => _message;

  void setQrScanned(bool value, String depot) {
    _isQrScanned = value;
    _depotName = depot;
    _message = 'QR Code validé - Panier déposé';
    notifyListeners();
  }
}