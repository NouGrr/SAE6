import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class LivreurScreen extends StatefulWidget {
  const LivreurScreen({super.key});

  @override
  _LivreurScreenState createState() => _LivreurScreenState();
}

class _LivreurScreenState extends State<LivreurScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String scannedData = "Aucun QR code scanné";

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Livreur - Scanner QR Code")),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.red,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 300,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(scannedData, style: const TextStyle(fontSize: 18)),
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
      setState(() {
        scannedData = scanData.code ?? "Aucune donnée";
      });
    });
  }
}

class TourMapScreen extends StatefulWidget {
  const TourMapScreen({super.key});

  @override
  _TourMapScreenState createState() => _TourMapScreenState();
}

class _TourMapScreenState extends State<TourMapScreen> {
  final List<LatLng> route = [
    LatLng(48.8566, 2.3522), // Paris
    LatLng(45.764, 4.8357), // Lyon
    LatLng(43.6047, 1.4442), // Toulouse
  ];
  LatLng? currentPosition;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) return;
    }

    Geolocator.getPositionStream().listen((Position position) {
      setState(() {
        currentPosition = LatLng(position.latitude, position.longitude);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gestion des Tournées")),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                onTap: (tapPosition, point) {
                  // Handle tap event here
                },
                crs: const Epsg3857(),
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
                PolylineLayer(polylines: [
                  Polyline(points: route, strokeWidth: 4.0, color: Colors.blue),
                ]),
                MarkerLayer(markers: [
                  for (var pos in route)
                    Marker(
                      width: 40.0,
                      height: 40.0,
                      point: pos,
                      builder: (BuildContext context) => const Icon(Icons.location_pin, color: Colors.red),
                    ),
                  if (currentPosition != null)
                    Marker(
                      width: 40.0,
                      height: 40.0,
                      point: currentPosition!,
                      builder: (BuildContext context) => const Icon(Icons.my_location, color: Colors.blue),
                    ),
                ]),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const QRScannerScreen()),
            ),
            child: const Text("Scanner un QR Code"),
          ),
        ],
      ),
    );
  }
}

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String scannedData = "Aucun QR code scanné";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scanner QR Code")),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: QRView(
              key: qrKey,
              onQRViewCreated: (QRViewController controller) {
                this.controller = controller;
                controller.scannedDataStream.listen((scanData) {
                  setState(() {
                    scannedData = scanData.code ?? "Aucune donnée";
                  });
                });
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(scannedData, style: const TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  
}
