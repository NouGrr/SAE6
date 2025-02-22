import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'dart:async';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_application_2/models/delivery_point.dart' as model;

class TourMapScreen extends StatefulWidget {
  final model.DeliveryPoint deliveryPoint;
  final String selectedDay;
  final String depotId;
  final String depot;
  final String quantity;
  final String address;
  final String postalCode;
  final String city;
  final String location;

  TourMapScreen({
    required this.deliveryPoint,
    required this.selectedDay,
    required this.depotId,
    required this.depot,
    required this.quantity,
    required this.address,
    required this.postalCode,
    required this.city,
    required this.location,
  });

  @override
  _TourMapScreenState createState() => _TourMapScreenState();
}

class _TourMapScreenState extends State<TourMapScreen> {
  static const String _tomTomApiKey = 'zSOGsmdG3zCKzA1CaGWaKhdSCjSR2Pqv';
  static const String _supabaseApiKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFqbmllenRwd253cm9pbnFyb2xtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzc4MTEwNTAsImV4cCI6MjA1MzM4NzA1MH0.orLZFmX3i_qR0H4H6WwhUilNf5a1EAfrFhbbeRvN41M';
  
  LatLng? _center;
  late final MapController _mapController;
  List<Marker> _markers = [];
  List<LatLng> _routePoints = [];
  List<String> _instructions = [];
  LatLng? _currentPosition;
  bool _isLoading = true;
  Timer? _locationTimer;
  bool _isGeneratingRoute = false;
  LatLng? _destinationPoint;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    await _getCurrentLocation();
    await _loadDeliveryPoint();
    _startLocationUpdates();
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }

  void _startLocationUpdates() {
    _locationTimer = Timer.periodic(Duration(seconds: 10), (Timer t) async {
      await _getCurrentLocation();
    });
  }

  Future<void> _loadDeliveryPoint() async {
  try {
      // Utiliser directement le point de livraison passé depuis liv_screen
      model.DeliveryPoint point = widget.deliveryPoint;
      
      _destinationPoint = LatLng(
        point.location[0], // Latitude
        point.location[1]  // Longitude
      );

      setState(() {
        _isLoading = false;
      });

      _markers.clear();
      _addMarker(
        _destinationPoint!,
        label: "${point.depot}\n${point.quantity} unités\n${point.address}, ${point.postalCode} ${point.city}",
        isDestination: true
      );

      if (_currentPosition != null) {
        await _generateTomTomRoute();
      }
    } catch (e) {
      print("Erreur lors du chargement du point de livraison: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Les services de localisation sont désactivés');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permission de localisation refusée');
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );

      if (mounted) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
          _center = _currentPosition;
          _updateCurrentLocationMarker();
        });
      }
    } catch (e) {
      print("Erreur de localisation: $e");
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
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Ma position',
                  style: TextStyle(fontSize: 10, color: Colors.black),
                ),
              ),
            ],
          );
        },
      ),
    );

    if (!_isGeneratingRoute && _destinationPoint != null) {
      _generateTomTomRoute();
    }
  }

  void _addMarker(LatLng position, {required String label, bool isDestination = false}) {
    _markers.add(
      Marker(
        point: position,
        width: 120,
        height: 100,
        builder: (BuildContext context) => Column(
          children: [
            Icon(
              isDestination ? Icons.location_on : Icons.place,
              color: isDestination ? Colors.red : Colors.blue,
              size: 30.0
            ),
            Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
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

  Future<void> _generateTomTomRoute() async {
    if (_currentPosition == null || _destinationPoint == null || _isGeneratingRoute) {
      print('Position actuelle ou destination manquante');
      return;
    }

    setState(() {
      _isGeneratingRoute = true;
    });

    try {
      final uri = Uri.https('api.tomtom.com', '/routing/1/calculateRoute/${_currentPosition!.latitude},${_currentPosition!.longitude}:${_destinationPoint!.latitude},${_destinationPoint!.longitude}/json', {
        'key': _tomTomApiKey,
        'instructionsType': 'text',
        'language': 'fr-FR',
        'routeType': 'fastest',
        'traffic': 'true',
        'travelMode': 'car',
      });

      print('URL TomTom: $uri');

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          var route = data['routes'][0];
          List<LatLng> points = [];
          List<String> newInstructions = [];

          for (var point in route['legs'][0]['points']) {
            points.add(LatLng(
              point['latitude'].toDouble(),
              point['longitude'].toDouble(),
            ));
          }

          for (var instruction in route['guidance']['instructions']) {
            newInstructions.add(instruction['message']);
          }

          if (mounted) {
            setState(() {
              _routePoints = points;
              _instructions = newInstructions;
            });
            _fitBounds();
          }
        }
      } else {
        print("Erreur API TomTom: ${response.statusCode}");
        print("Response: ${response.body}");
      }
    } catch (e) {
      print('Erreur lors de la génération de l\'itinéraire: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingRoute = false;
        });
      }
    }
  }

  void _fitBounds() {
    if (_routePoints.isEmpty) return;
    
    double minLat = _routePoints.map((p) => p.latitude).reduce((a, b) => a < b ? a : b);
    double maxLat = _routePoints.map((p) => p.latitude).reduce((a, b) => a > b ? a : b);
    double minLng = _routePoints.map((p) => p.longitude).reduce((a, b) => a < b ? a : b);
    double maxLng = _routePoints.map((p) => p.longitude).reduce((a, b) => a > b ? a : b);

    double padding = 0.1;
    LatLngBounds bounds = LatLngBounds(
      LatLng(minLat - padding, minLng - padding),
      LatLng(maxLat + padding, maxLng + padding),
    );

    _mapController.fitBounds(
      bounds,
      options: FitBoundsOptions(
        padding: EdgeInsets.all(50.0),
        maxZoom: 15.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Itinéraire de Livraison'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _generateTomTomRoute,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  flex: 2,
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      center: _center ?? LatLng(48.8566, 2.3522),
                      zoom: 13.0,
                      maxZoom: 18.0,
                      interactiveFlags: InteractiveFlag.all,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                        subdomains: ['a', 'b', 'c'],
                      ),
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _routePoints,
                            color: Colors.blue,
                            strokeWidth: 4.0,
                          ),
                        ],
                      ),
                      MarkerLayer(
                        markers: _markers,
                      ),
                    ],
                  ),
                ),
                if (_instructions.isNotEmpty)
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 5,
                            offset: Offset(0, -2),
                          ),
                        ],
                      ),
                      child: ListView.builder(
                        itemCount: _instructions.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: Icon(Icons.directions),
                            title: Text(
                              _instructions[index],
                              style: TextStyle(fontSize: 14),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}