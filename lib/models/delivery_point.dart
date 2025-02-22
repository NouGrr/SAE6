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
    try {
      var coordinates = json['adresses']['localisation']['coordinates'] as List;
      
      // Gestion de la quantité avec le champ 'sum' au lieu de 'qte.sum()'
      double qty = 0.0;
      var rawQty = json['sum']; // Changé de 'qte.sum()' à 'sum'
      if (rawQty != null) {
        qty = (rawQty is int) ? rawQty.toDouble() : double.parse(rawQty.toString());
      }

      return DeliveryPoint(
        depotId: json['depot_id'] ?? 0,
        depot: json['depot'] ?? '',
        quantity: qty,
        address: json['adresses']['adresse'] ?? '',
        postalCode: json['adresses']['codepostal'] ?? '',
        city: json['adresses']['ville'] ?? '',
        location: [
          coordinates[1].toDouble(), // Latitude
          coordinates[0].toDouble()  // Longitude
        ],
      );
    } catch (e, stackTrace) {
      print('Erreur dans DeliveryPoint.fromJson: $e');
      print('Stack trace: $stackTrace');
      print('JSON reçu: $json');
      rethrow;
    }
  }

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is DeliveryPoint &&
    runtimeType == other.runtimeType &&
    depotId == other.depotId;

  @override
  int get hashCode => depotId.hashCode;
}