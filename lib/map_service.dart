import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'map_service.dart';
import 'gps_service.dart';
import 'qr_scanner_service.dart';


class MapService {
  static Widget buildMap(List<LatLng> route, LatLng? currentPosition) {
    return FlutterMap(
      options: MapOptions(
        onTap: (tapPosition, point) {
          // Handle tap event
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
              child: const Icon(Icons.location_pin, color: Colors.red),
            ),
          if (currentPosition != null)
            Marker(
              width: 40.0,
              height: 40.0,
              point: currentPosition,
              child: const Icon(Icons.my_location, color: Colors.blue),
            ),
        ]),
      ],
    );
  }
}
