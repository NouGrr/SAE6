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
    required this.location, required id, required tournee,
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
        location: [0, 0], id: null, tournee: null,
      );
      id: json['adresses']['id'];
      tournee: json['adresses']['tournee'];
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
      id: json['adresses']['id'],
      tournee: json['adresses']['tournee'],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeliveryPoint &&
          runtimeType == other.runtimeType &&
          depotId == other.depotId &&
          depot == other.depot &&
          quantity == other.quantity &&
          address == other.address &&
          postalCode == other.postalCode &&
          city == other.city &&
          location[0] == other.location[0] &&
          location[1] == other.location[1];

  @override
  int get hashCode =>
      depotId.hashCode ^
      depot.hashCode ^
      quantity.hashCode ^
      address.hashCode ^
      postalCode.hashCode ^
      city.hashCode ^
      location[0].hashCode ^
      location[1].hashCode;
}