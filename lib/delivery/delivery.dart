import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/delivery/panier.dart';

const apikey = String.fromEnvironment('api_key', defaultValue: '0');

class DeliveryPage extends StatefulWidget {
  const DeliveryPage({super.key});

  @override
  State<StatefulWidget> createState() => _DeliveryPageState();
}

class _DeliveryPageState extends State<DeliveryPage> {
  late Future<List<Tournee>> futureTournees;

  @override
  void initState() {
    super.initState();
    futureTournees = fetchTournees();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tournées de livraison'),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade50, Colors.white],
          ),
        ),
        child: FutureBuilder(
          future: futureTournees,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<Tournee> tournees = snapshot.data as List<Tournee>;
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  itemCount: tournees.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(15),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BasketPage(
                                  tourneeId: tournees[index].tourneeId.toString()
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Color(int.parse(tournees[index].couleur.replaceAll('#', '0xff'))).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.local_shipping,
                                    color: Color(int.parse(tournees[index].couleur.replaceAll('#', '0xff'))),
                                    size: 30,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tournees[index].tournee,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Tournée n°${tournees[index].tourneeId}',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.grey[400],
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 60,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Erreur de chargement',
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              );
            }

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Chargement des tournées...',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

Future<List<Tournee>> fetchTournees() async {
  final response = await http.get(
    Uri.parse('https://qjnieztpwnwroinqrolm.supabase.co/rest/v1/tournees'),
    headers: {
      'Content-Type': 'application/json',
      'apikey': apikey,
    },
  );

  if (response.statusCode == 200) {
    List<dynamic> jsonResponse = jsonDecode(response.body) as List<dynamic>;
    return jsonResponse.map((data) => Tournee.fromJson(data as Map<String, dynamic>)).toList();
  } else {
    throw Exception('Failed to load tournees');
  }
}

class Tournee {
  final int tourneeId;
  final int jardinId;
  final String tournee;
  final int preparationId;
  final int calendrierId;
  final int ordre;
  final String couleur;

  Tournee({
    required this.tourneeId,
    required this.jardinId,
    required this.tournee,
    required this.preparationId,
    required this.calendrierId,
    required this.ordre,
    required this.couleur,
  });

  factory Tournee.fromJson(Map<String, dynamic> json) {
    return Tournee(
      tourneeId: json['tournee_id'],
      jardinId: json['jardin_id'],
      tournee: json['tournee'],
      preparationId: json['preparation_id'],
      calendrierId: json['calendrier_id'],
      ordre: json['ordre'],
      couleur: json['couleur'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tournee_id': tourneeId,
      'jardin_id': jardinId,
      'tournee': tournee,
      'preparation_id': preparationId,
      'calendrier_id': calendrierId,
      'ordre': ordre,
      'couleur': couleur,
    };
  }
}