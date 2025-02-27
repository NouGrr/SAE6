import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import "package:flutter_map/flutter_map.dart";
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '/delivery/app_state.dart';

const apikey = String.fromEnvironment('api_key', defaultValue: '0');
const tomtomkey = String.fromEnvironment('tomtom_key', defaultValue: 'zSOGsmdG3zCKzA1CaGWaKhdSCjSR2Pqv');

class ItineraryPage extends StatefulWidget {
  final String tourneeId;

  const ItineraryPage({super.key, required this.tourneeId});
  @override
  _ItineraryPageState createState() => _ItineraryPageState();
}

class _ItineraryPageState extends State<ItineraryPage> {
  List<dynamic> depotData = [];
  bool isLoading = true;
  bool isLocated = false;
  bool isRouted = false;
  int depotIndex = 0;
  LatLng userLocation = LatLng(0, 0);
  List<LatLng> routeData = [];
  MapController mapController = MapController();

  @override
  void initState() {
    super.initState();
    fetchItineraryData();
    determinePosition();
  }

  Future<void> fetchItineraryData() async {
    final response = await http.get(
      Uri.parse('https://qjnieztpwnwroinqrolm.supabase.co/rest/v1/detail_livraisons?tournee_id=eq.${widget.tourneeId}&select=depot_id,depot,qte.sum(),adresses(adresse,codepostal,ville,localisation)'),
      headers: {
        'apikey': apikey,
        'Authorization': 'Bearer $apikey',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        depotData = json.decode(response.body);
        depotData.removeWhere((depot) => depot['adresses'] == null);
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load depot data: ${response.statusCode}');
    }
  }

  Future<void> determinePosition() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        userLocation = LatLng(position.latitude, position.longitude);
        isLocated = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de localisation: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> getRoute() async {
    if (!isLocated || depotData.isEmpty) return;

    // Correction de l'ordre des coordonnées pour TomTom (latitude,longitude)
    final start = '${userLocation.latitude},${userLocation.longitude}';
    final end = '${depotData[depotIndex]["adresses"]["localisation"]["coordinates"][1]},${depotData[depotIndex]["adresses"]["localisation"]["coordinates"][0]}';
    
    try {
      final response = await http.get(
        Uri.parse('https://api.tomtom.com/routing/1/calculateRoute/$start:$end/json?key=$tomtomkey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          routeData = (data['routes'][0]['legs'][0]['points'] as List)
              .map((point) => LatLng(point['latitude'], point['longitude']))
              .toList();
          isRouted = true;
        });

        // Centre la carte sur l'itinéraire
        if (routeData.isNotEmpty) {
          final bounds = LatLngBounds.fromPoints(routeData);
          mapController.fitBounds(
            bounds,
            options: FitBoundsOptions(
              padding: EdgeInsets.all(50.0),
            ),
          );
        }
      } else {
        throw Exception('Erreur TomTom API: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de calcul d\'itinéraire: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des dépôts'),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: FutureBuilder(
        future: Future.wait([
          isLoading ? fetchItineraryData() : Future.value(null),
          !isLocated ? determinePosition() : Future.value(null),
          isLocated && !isRouted ? getRoute() : Future.value(null),
        ]),
        builder: (context, snapshot) {
          if (isLoading || !isLocated || !isRouted) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                  SizedBox(height: 16),
                  Text(
                    !isLocated ? "Localisation en cours..." :
                    !isRouted ? "Calcul de l'itinéraire..." :
                    "Chargement des données...",
                    style: TextStyle(color: Colors.green[800]),
                  ),
                ],
              ),
            );
          }

          return FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialZoom: 13.0,
              minZoom: 3.0,
              maxZoom: 18.0,
              initialCenter: userLocation,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(
                      depotData[depotIndex]["adresses"]["localisation"]["coordinates"][1],
                      depotData[depotIndex]["adresses"]["localisation"]["coordinates"][0]
                    ),
                    width: 120,
                    height: 100,
                    child: Column(
                      children: [
                        Icon(Icons.location_pin, color: Colors.red, size: 50),
                        Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            "${depotData[depotIndex]["depot"] ?? 'Dépôt inconnu'}\n" +
                            "${((depotData[depotIndex]["qte"] as Map<String, dynamic>?)?["sum"] ?? 0).toString()} unités",
                            style: TextStyle(fontSize: 12, color: Colors.black),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Marker(
                    point: userLocation,
                    width: 50,
                    height: 50,
                    child: Icon(Icons.local_shipping, color: Colors.blue, size: 40),
                  ),
                ],
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: routeData,
                    strokeWidth: 4.0,
                    color: Colors.blue,
                  ),
                ],
              ),
            ],
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildScanButton(),
    );
  }

  Widget _buildScanButton() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            colors: [Colors.green.shade400, Colors.green.shade700],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: showQRScanner,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.qr_code_scanner, color: Colors.white, size: 24),
                  SizedBox(width: 10),
                  Text(
                    'Scanner QR Code',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

void showQRScanner() {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Scanner le QR Code',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Dépôt actuel : ${depotData[depotIndex]["depot"]}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 20),
              Container(
                height: 300,
                width: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.green.shade200, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: MobileScanner(
                    controller: MobileScannerController(
                      detectionSpeed: DetectionSpeed.normal,
                      facing: CameraFacing.back,
                    ),
                    onDetect: _handleScannedBarcode,
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Text(
                    'Annuler',
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

void _handleScannedBarcode(BarcodeCapture capture) async {
  final List<Barcode> barcodes = capture.barcodes;
  if (barcodes.isEmpty) return;

  final barcode = barcodes.first;
  if (barcode.rawValue == null) {
    _showErrorSnackBar('QR Code invalide');
    return;
  }

  Navigator.of(context).pop();

  String scannedValue = barcode.rawValue!.toString();
  print("QR Code scanné : $scannedValue");

  // Si le QR code est valide, continue avec l'action mais affiche le nom du dépôt
  if (scannedValue.isNotEmpty) {
    await _handleValidQRCode(context);
  } else {
    _showErrorSnackBar('QR Code invalide');
  }
}

void _showErrorSnackBar(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
      duration: Duration(seconds: 3),
    ),
  );
}

Future<void> _handleValidQRCode(BuildContext context) async {
  // Affichage du dialogue avec le nom du dépôt
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Column(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 50,
            ),
            SizedBox(height: 10),
            Text(
              'QR Code validé !',
              style: TextStyle(
                color: Colors.green[800],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'Le dépôt actuel est : ${depotData[depotIndex]["depot"]}\nVoulez-vous passer au dépôt suivant ?',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            child: Text(
              'Plus tard',
              style: TextStyle(color: Colors.grey),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              _updateDeliveryStatus();
            },
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              'Oui, suivant',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              _updateDeliveryStatus();
              _moveToNextDepot();
            },
          ),
        ],
      );
    },
  );
}

void _updateDeliveryStatus() {
  // Mettre à jour l'état de la livraison avec une action générique
  Provider.of<AppState>(context, listen: false).setQrScanned(true, depotData[depotIndex]["depot"]);
}

void _moveToNextDepot() {
  if (depotIndex < depotData.length - 1) {
    setState(() {
      depotIndex++;
      isLocated = false;
      isRouted = false;
    });
    Future.wait([determinePosition(), getRoute()]);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Toutes les livraisons ont été effectuées'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 3),
      ),
    );
  }
}
  }
  
  FitBoundsOptions({required EdgeInsets padding}) {}

extension on MapController {
  void fitBounds(LatLngBounds bounds, {required options}) {}
}