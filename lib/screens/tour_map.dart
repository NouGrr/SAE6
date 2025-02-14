import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'dart:async';

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

  @override
  void initState() {
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

        // Trier les points de livraison par depotId
        deliveryPoints.sort((a, b) => a.depotId.compareTo(b.depotId));
        
        setState(() {
          _routePoints = deliveryPoints
            .map((point) => LatLng(point.location[0], point.location[1]))
            .where((point) => point.latitude != 0 && point.longitude != 0)
            .toList();
          _isLoading = false;
        });

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
        child: Column(
          children: [
            Icon(Icons.directions_car, color: Colors.blue, size: 30.0),
            Text('Véhicule', style: TextStyle(fontSize: 12, color: Colors.black)),
          ],
        ),
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
        child: Column(
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
      String url = 'https://router.project-osrm.org/route/v1/driving/'
          '${orderedPoints[i].longitude},${orderedPoints[i].latitude};'
          '${orderedPoints[i + 1].longitude},${orderedPoints[i + 1].latitude}'
          '?overview=full&geometries=polyline';

      try {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          var data = jsonDecode(response.body);
          if (data['routes'] != null && data['routes'].isNotEmpty) {
            String geometry = data['routes'][0]['geometry'];
            List<LatLng> segmentRoute = _decodePolyline(geometry);
            fullRoute.addAll(segmentRoute);
          } else {
            print('Erreur: Pas de routes trouvées');
          }
          
          await Future.delayed(Duration(milliseconds: 500));
        } else {
          print('Erreur lors de la récupération de l\'itinéraire: ${response.body}');
        }
      } catch (e) {
        print('Erreur lors de la génération du segment ${i}: $e');
      }
    }

    setState(() {
      _routePoints = fullRoute;
    });
    
    _fitBounds();
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  void _fitBounds() {
    if (_routePoints.isEmpty) return;
    
    double minLat = _routePoints.map((p) => p.latitude).reduce((a, b) => a < b ? a : b);
    double maxLat = _routePoints.map((p) => p.latitude).reduce((a, b) => a > b ? a : b);
    double minLng = _routePoints.map((p) => p.longitude).reduce((a, b) => a < b ? a : b);
    double maxLng = _routePoints.map((p) => p.longitude).reduce((a, b) => a > b ? a : b);

    final bounds = LatLngBounds(
      LatLng(minLat, minLng),
      LatLng(maxLat, maxLng),
    );

    _mapController.fitBounds(
      bounds,
      options: const FitBoundsOptions(padding: EdgeInsets.all(50.0)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Itinéraire de livraison'),
      ),
      body: Column(
        children: [
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
          if (!_isLoading)
            Expanded(
              child: _currentPosition == null
                  ? const Center(child: CircularProgressIndicator())
                  : FlutterMap(
                      options: MapOptions(
                        initialCenter: _currentPosition ?? LatLng(48.290052, 6.941962),
                        initialZoom: 15.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                          subdomains: ['a', 'b', 'c'],
                        ),
                        MarkerLayer(markers: _markers),
                        if (_routePoints.isNotEmpty)
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: _routePoints,
                                strokeWidth: 5.0,
                                color: Colors.blue,
                              ),
                            ],
                          ),
                      ],
                    ),
            ),
        ],
      ),
    );
  }
}

class FitBoundsOptions {
  const FitBoundsOptions({required EdgeInsets padding});
}

extension on MapController {
  void fitBounds(LatLngBounds bounds, {required options}) {}
}