import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:ui_web' as ui_web;
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'dart:html' as html;

class QrScreen extends StatefulWidget {
  @override
  _QrScreenState createState() => _QrScreenState();
}

class _QrScreenState extends State<QrScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String scannedData = '';
  String depotData = ''; // Pour stocker les informations du dépôt
  bool isDepotScanned = false;
  bool isPackageScanned = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Scanner QR Code')),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                scannedData.isEmpty
                    ? 'Scanne un QR Code'
                    : isDepotScanned
                        ? isPackageScanned
                            ? 'Prochain dépôt: $depotData'
                            : 'Panier scanné: $scannedData\nValide la livraison pour continuer.'
                        : 'Dépôt scanné: $scannedData\nScannez maintenant un panier.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        scannedData = scanData.code ?? '';
        _handleScan();
      });
    });
  }

  void _handleScan() {
    if (!isDepotScanned) {
      // Si un dépôt n'est pas encore scanné, on enregistre ce dépôt.
      depotData = scannedData;
      isDepotScanned = true;
      scannedData = ''; // Reset pour scanner le panier
    } else if (isDepotScanned && !isPackageScanned) {
      // Si un dépôt est scanné et un panier n'est pas encore scanné.
      isPackageScanned = true; // Validation du panier
    } else if (isDepotScanned && isPackageScanned) {
      // Si un dépôt et un panier sont scannés, on prépare pour le prochain dépôt.
      depotData = scannedData;
      isDepotScanned = false;
      isPackageScanned = false;
      scannedData = ''; // Reset pour scanner un nouveau panier ou dépôt
    }
  }
}

