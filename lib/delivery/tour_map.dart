import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import "package:flutter_map/flutter_map.dart";
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:sae_cocagne_mobile/delivery/app_state.dart';

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
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        depotData = json.decode(response.body);
        depotData.removeWhere((depot) => depot['adresses'] == null);
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load depot data');
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
          if (isLoading) {
            return Center(child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ));
          } else if (!isLocated) {
            return Center(child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ));
          } else if (!isRouted) {
            return Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
                SizedBox(height: 16),
                Text(
                  "Calcul de l'itinéraire...",
                  style: TextStyle(color: Colors.green[800]),
                ),
              ],
            ));
          } else {
            return FlutterMap(
              mapController: MapController(),
              options: MapOptions(
                initialZoom: 8.0,
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
                              // Modification de l'accès aux données avec vérification null-safety
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
                      points: routeData.isNotEmpty ? routeData : [
                        LatLng(depotData[depotIndex]["adresses"]["localisation"]["coordinates"][1],
                        depotData[depotIndex]["adresses"]["localisation"]["coordinates"][0]),
                        userLocation,
                      ],
                      strokeWidth: 4.0,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ],
            );
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
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
              onTap: () {
                showDialog(
                  context: context,
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
                                  onDetect: (capture) {
                                    final List<Barcode> barcodes = capture.barcodes;
                                    for (final barcode in barcodes) {
                                      if (barcode.rawValue != null) {
                                        Navigator.of(context).pop();
                                        
                                        showDialog(
                                          context: context,
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
                                                  Text('QR Code validé !'),
                                                ],
                                              ),
                                              content: Text(
                                                'Voulez-vous passer au dépôt suivant ?'
                                              ),
                                              actions: [
                                                TextButton(
                                                  child: Text(
                                                    'Plus tard',
                                                    style: TextStyle(color: Colors.grey),
                                                  ),
                                                  onPressed: () => Navigator.of(context).pop(),
                                                ),
                                                ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.green,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(30),
                                                    ),
                                                  ),
                                                  child: Text('Oui, suivant'),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                    if (depotIndex < depotData.length - 1) {
                                                      setState(() {
                                                        depotIndex++;
                                                        isLocated = false;
                                                        isRouted = false;
                                                      });
                                                      Future.wait([
                                                        determinePosition(),
                                                        getRoute(),
                                                      ]);
                                                    } else {
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(
                                                          content: Text('Toutes les livraisons ont été effectuées'),
                                                          backgroundColor: Colors.orange,
                                                        )
                                                      );
                                                    }
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );

                                        Provider.of<AppState>(context, listen: false)
                                            .setQrScanned(true, depotData[depotIndex]["depot"]);
                                      }
                                    }
                                  },
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            TextButton(
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  side: BorderSide(color: Colors.grey.shade300),
                                ),
                              ),
                              child: Text('Annuler'),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              child: Container(
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
      ),
    );
  }
  
  Future<void> determinePosition() async {
    Geolocator.getCurrentPosition().then((Position position) {
      setState(() {
        userLocation = LatLng(position.latitude, position.longitude);
        isLocated = true;
      });
    }).catchError((e) {
      throw Exception('Failed to get user location');
    });
  }

  Future<void> getRoute() async {
    final start = '${userLocation.latitude},${userLocation.longitude}';
    final end = '${depotData[depotIndex]["adresses"]["localisation"]["coordinates"][1]},${depotData[depotIndex]["adresses"]["localisation"]["coordinates"][0]}';
    final response = await http.get(
      Uri.parse("https://api.tomtom.com/routing/1/calculateRoute/$start:$end/json?avoid=unpavedRoads&key=$tomtomkey"),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        routeData = (data['routes'][0]['legs'][0]['points'] as List)
            .map((point) => LatLng(point['latitude'], point['longitude']))
            .toList();
        isRouted = true;
      });
    }
  }
}