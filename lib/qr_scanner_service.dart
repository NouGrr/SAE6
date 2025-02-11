import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRScannerService extends StatefulWidget {
  final Function(String) onScanned;

  const QRScannerService({Key? key, required this.onScanned}) : super(key: key);

  @override
  _QRScannerServiceState createState() => _QRScannerServiceState();
}

class _QRScannerServiceState extends State<QRScannerService> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      widget.onScanned(scanData.code ?? '');
    });
  }
}
