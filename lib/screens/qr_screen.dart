import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'app_state.dart';

class QrScreen extends StatefulWidget {
  @override
  _QrScreenState createState() => _QrScreenState();
}

class _QrScreenState extends State<QrScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String scannedData = '';
  String depotData = '';
  bool isDepotScanned = false;
  bool isPackageScanned = false;
  bool _mounted = true;
  final String nextDepot = 'Ligue de l\'enseignement\n15 rue Général de Reffye\n88000 Epinal';

  @override
  void initState() {
    super.initState();
    _mounted = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scanner QR Code'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.black,
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.width * 0.8,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Transform.scale(
                          scale: 1.5, // Adjust this value to zoom in/out
                          child: QRView(
                            key: qrKey,
                            onQRViewCreated: _onQRViewCreated,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.green, width: 2.0),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: isPackageScanned ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isPackageScanned ? Colors.green : Colors.grey,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              scannedData.isEmpty
                                  ? 'Scannez un QR Code'
                                  : isDepotScanned
                                      ? isPackageScanned
                                          ? 'Livraison validée !'
                                          : 'Panier scanné: $scannedData'
                                      : 'Dépôt scanné: $scannedData',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isPackageScanned ? Colors.green : Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (isPackageScanned) ...[
                              SizedBox(height: 20),
                              Text(
                                'Prochain dépôt :',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                nextDepot,
                                style: TextStyle(fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 16),
                              Icon(Icons.arrow_forward, color: Colors.green, size: 40),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
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
      if (!isPackageScanned && _mounted) {
        setState(() {
          scannedData = scanData.code ?? '';
          _handleScan();
        });
      }
    });
  }

  void _handleScan() {
    if (!_mounted) return;

    if (!isDepotScanned) {
      setState(() {
        depotData = scannedData;
        isDepotScanned = true;
        scannedData = '';
      });
    } else if (isDepotScanned && !isPackageScanned) {
      setState(() {
        isPackageScanned = true;
        try {
          controller?.pauseCamera();
        } catch (e) {
          print('Impossible de mettre en pause la caméra: $e');
        }
      });
      if (_mounted) {
        Provider.of<AppState>(context, listen: false).setQrScanned(true);
      }
    }
  }

  @override
  void dispose() {
    _mounted = false;
    controller?.dispose();
    super.dispose();
  }
}