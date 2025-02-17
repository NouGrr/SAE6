import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'dart:async';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';


class DeliveryPoint {
  final int depotId;
  final String depot;
  final double quantity;
  final String address;
  final String postalCode;
  final String city;
  final List<double> location;

  DeliveryPoint({
    required this.depotId,
    required this.depot,
    required this.quantity,
    required this.address,
    required this.postalCode,
    required this.city,
    required this.location,
  });

  factory DeliveryPoint.fromJson(Map<String, dynamic> json) {
    if (json['adresses'] == null) {
      return DeliveryPoint(
        depotId: json['depot_id'],
        depot: json['depot'],
        quantity: (json['qte'] as num).toDouble(),
        address: '',
        postalCode: '',
        city: '',
        location: [0, 0],
      );
    }

    final coordinates = json['adresses']['localisation']['coordinates'] as List;
    
    return DeliveryPoint(
      depotId: json['depot_id'],
      depot: json['depot'],
      quantity: (json['qte'] as num).toDouble(),
      address: json['adresses']['adresse'],
      postalCode: json['adresses']['codepostal'],
      city: json['adresses']['ville'],
      location: [
        coordinates[1].toDouble(), // Latitude
        coordinates[0].toDouble()  // Longitude
      ],
    );
  }
}

class TourMapScreen extends StatefulWidget {
  final String selectedDay;
  TourMapScreen({required this.selectedDay});

  @override
  _TourMapScreenState createState() => _TourMapScreenState();
}

class _TourMapScreenState extends State<TourMapScreen> {
  LatLng? _center;
  late final MapController _mapController;
  List<Marker> _markers = [];
  List<LatLng> _routePoints = [];
  LatLng? _currentPosition;
  bool _isLoading = true;
  Timer? _locationTimer;
  final String googleMapsApiKey = 'AIzaSyA_1OfCABTNa9S4LwxykJFJcrTje4_i-q0'; // Votre clé API
  late MarkerLayerOptions _markerLayerOptions;
  late PolylineLayerOptions _polylineLayerOptions;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _getCurrentLocation();
    _loadAllRoutes();
    _startLocationUpdates();
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }

  void _startLocationUpdates() {
    _locationTimer = Timer.periodic(Duration(seconds: 5), (Timer t) async {
      await _getCurrentLocation();
    });
  }

  Future<void> _loadAllRoutes() async {
    try {
      final response = await http.get(
        Uri.parse('https://qjnieztpwnwroinqrolm.supabase.co/rest/v1/detail_livraisons?semaine=eq.9&tournee_id=eq.7&select=depot_id,depot,qte,adresses(adresse,codepostal,ville,localisation)'),
        headers: {
          'apikey': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFqbmllenRwd253cm9pbnFyb2xtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzc4MTEwNTAsImV4cCI6MjA1MzM4NzA1MH0.orLZFmX3i_qR0H4H6WwhUilNf5a1EAfrFhbbeRvN41M',
          'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFqbmllenRwd253cm9pbnFyb2xtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzc4MTEwNTAsImV4cCI6MjA1MzM4NzA1MH0.orLZFmX3i_qR0H4H6WwhUilNf5a1EAfrFhbbeRvN41M'
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('Données reçues: $data');

        List<DeliveryPoint> deliveryPoints = data
          .where((json) => json['adresses'] != null)
          .map((json) => DeliveryPoint.fromJson(json))
          .toList();

        deliveryPoints.sort((a, b) => a.depotId.compareTo(b.depotId));

        setState(() {
          _routePoints = deliveryPoints
            .map((point) => LatLng(point.location[0], point.location[1]))
            .where((point) => point.latitude != 0 && point.longitude != 0)
            .toList();
          _isLoading = false;
        });

        _markers.clear();
        for (var point in deliveryPoints) {
          if (point.location[0] != 0 && point.location[1] != 0) {
            _addMarker(
              LatLng(point.location[0], point.location[1]),
              label: "${point.depot}\n${point.quantity} unités\n${point.address}"
            );
          }
        }

        if (_routePoints.isNotEmpty) {
          _generateRoute();
        }

        // Initialisation des layers
        _markerLayerOptions = MarkerLayerOptions(markers: _markers);
        _polylineLayerOptions = PolylineLayerOptions(polylines: [
          Polyline(
            points: _routePoints,
            strokeWidth: 4.0,
            color: Colors.blue,
          ),
        ]);
      } else {
        print("Erreur API: ${response.statusCode}");
        print("Response: ${response.body}");
      }
    } catch (e) {
      print("Erreur lors du chargement des itinéraires: $e");
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition();
    if (mounted) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _center = _currentPosition;
        _updateCurrentLocationMarker();
      });
    }
  }

  void _updateCurrentLocationMarker() {
    if (_currentPosition == null) return;

    _markers.removeWhere((marker) => marker.key == ValueKey('current_location'));

    _markers.add(
      Marker(
        key: ValueKey('current_location'),
        point: _currentPosition!,
        width: 50,
        height: 50,
        builder: (BuildContext context) {
          return Column(
            children: [
              Icon(Icons.directions_car, color: Colors.blue, size: 30.0),
              Text('Véhicule', style: TextStyle(fontSize: 12, color: Colors.black)),
            ],
          );
        },
      ),
    );

    if (_markers.length > 1) {
      _generateRoute();
    }
  }

  void _addMarker(LatLng position, {String label = "Point de livraison"}) {
    _markers.add(
      Marker(
        point: position,
        width: 120,
        height: 100,
        builder: (BuildContext context) => Column(
          children: [
            Icon(Icons.location_on, color: Colors.red, size: 30.0),
            Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                label,
                style: TextStyle(fontSize: 10, color: Colors.black),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ), 
      ),
    );
  }

  Future<void> _generateRoute() async {
    if (_currentPosition == null || _routePoints.isEmpty) return;

    List<LatLng> fullRoute = [];
    List<LatLng> orderedPoints = [
      _currentPosition!,
      ..._routePoints,
    ];

    for (int i = 0; i < orderedPoints.length - 1; i++) {
      String url = 'https://maps.googleapis.com/maps/api/directions/json?origin=${orderedPoints[i].latitude},${orderedPoints[i].longitude}&destination=${orderedPoints[i + 1].latitude},${orderedPoints[i + 1].longitude}&key=$googleMapsApiKey';

      try {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          var data = jsonDecode(response.body);
          if (data['routes'] != null && data['routes'].isNotEmpty) {
            String geometry = data['routes'][0]['overview_polyline']['points'];
            List<LatLng> segmentRoute = _decodePolyline(geometry);
            fullRoute.addAll(segmentRoute);
          } else {
            print("Aucune route trouvée entre les points.");
          }
        }
      } catch (e) {
        print("Erreur de récupération de l'itinéraire: $e");
      }
    }

    setState(() {
      if (fullRoute.isNotEmpty) {
        _markers.add(Marker(
          point: orderedPoints.last,
          width: 120,
          height: 100,
          builder: (BuildContext context) => Icon(Icons.location_on, color: Colors.green, size: 30.0),
        ));

        _mapController.fitBounds(LatLngBounds.fromPoints(fullRoute));
      }
    });
  }

  List<LatLng> _decodePolyline(String polyline) {
    List<LatLng> points = [];
    int index = 0;
    int len = polyline.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;
      do {
        b = polyline.codeUnitAt(index) - 63;
        index++;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = polyline.codeUnitAt(index) - 63;
        index++;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Itinéraire de Livraison'),
    ),
    body: _isLoading
        ? Center(child: CircularProgressIndicator())
        : FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      center: _center ?? LatLng(48.8566, 2.3522), // Paris par défaut
                      zoom: 10.0,
                      maxZoom: 18.0,
                    ),
                    children: [
                      // La couche de carte de base (OpenStreetMap)
                      TileLayer(
                        urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                        subdomains: ['a', 'b', 'c'],
                      ),
                      // Ajouter les markers si on en a
                      if (_markers.isNotEmpty)
                        MarkerLayer(
                          markers: _markers,
                        ),
                      // Ajouter les polylines si on en a
                    ],
                  ),
  );
}
}

class TileLayerOptions {
  final String urlTemplate;
  final List<String> subdomains;
  
  TileLayerOptions({required this.urlTemplate, required this.subdomains});
}


extension on MapController {
  void fitBounds(LatLngBounds latLngBounds) {
    // Ici tu peux mettre la logique pour ajuster la vue sur les bornes
    // Par exemple, tu peux utiliser des méthodes pour adapter la carte aux coordonnées.
  }
}

class MarkerLayerOptions {
  final List<Marker> markers;
  
  MarkerLayerOptions({required this.markers});
}

class PolylineLayerOptions {
  final List<Polyline> polylines;

  PolylineLayerOptions({required this.polylines});
}

class Polyline {
  final List<LatLng> points;
  final double strokeWidth;
  final Color color;

  Polyline({required this.points, required this.strokeWidth, required this.color});
}

class layers{
  final List<TileLayerOptions> TileLayer;
  final List<MarkerLayerOptions> MarkerLayer;
  final List<PolylineLayerOptions> PolylineLayer;

  layers({required this.TileLayer, required this.MarkerLayer, required this.PolylineLayer});
}