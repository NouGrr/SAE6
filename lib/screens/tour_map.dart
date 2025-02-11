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
  List<Marker> _markers = [];
  List<LatLng> _routePoints = [];
  final String _apiKey = '5b3ce3597851110001cf62488a9cdb2b0326420399c4bbfc720bcf99';
  LatLng? _currentPosition;
  bool _isLoading = true;
  Timer? _locationTimer;

  @override
  void initState() {
    super.initState();
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

    List<List<double>> coordinates = [
      [_currentPosition!.longitude, _currentPosition!.latitude],
      ..._routePoints.map((m) => [m.longitude, m.latitude]).toList(),
    ];

    String url = 'https://api.openrouteservice.org/v2/directions/driving-car/geojson';

    var body = jsonEncode({
      "coordinates": coordinates,
      "instructions": false,
      "elevation": false,
      "geometry_simplify": false
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Authorization": _apiKey,
          "Content-Type": "application/json"
        },
        body: body,
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        List<dynamic> coords = data['features'][0]['geometry']['coordinates'];
        List<LatLng> route = coords.map((c) => LatLng(c[1], c[0])).toList();

        setState(() {
          _routePoints = route;
        });
      } else {
        print('Erreur lors de la récupération de l\'itinéraire: ${response.body}');
      }
    } catch (e) {
      print('Erreur lors de la génération de l\'itinéraire: $e');
    }
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