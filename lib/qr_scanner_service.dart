import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'screens/app_state.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text('Scanner un QR code'),
      ),
      body: Column(
        children: <Widget>[
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
              child: Text('Scannez un QR code'),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      widget.onScanned(scanData.code ?? '');
      Provider.of<AppState>(context, listen: false).setQrScanned(true);
    });
  }
}