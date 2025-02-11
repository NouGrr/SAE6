import 'dart:convert';

import 'package:mysql1/mysql1.dart';
import 'package:latlong2/latlong.dart';

class DatabaseService {
  static Future<List<LatLng>> getAllRoutes() async {
    final conn = await MySqlConnection.connect(ConnectionSettings(
      host: 'localhost',
      port: 3306,
      user: 'root',
      db: 'sae6',
    ));

    // Récupérer les itinéraires depuis la base de données
    var results = await conn.query('SELECT points FROM itineraires');
    List<LatLng> latLngList = [];

    for (var row in results) {
      var points = row[0] as String;  // points est une chaîne de caractères contenant les données JSON
      List<dynamic> parsedPoints = jsonDecode(points);  // Convertir la chaîne JSON en une liste
      for (var point in parsedPoints) {
        latLngList.add(LatLng(point['lat'], point['lng']));
      }
    }

    await conn.close();
    return latLngList;
  }
}
