import 'package:flutter/material.dart';
import 'package:flutter_application_2/screens/panier.screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_application_2/models/delivery_point.dart' as model; // Importez la classe DeliveryPoint
import 'tour_map.dart' as screen;
import 'qr_screen.dart'; // Importez la page QR

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    SubscriptionScreen(),
    PanierScreen(simplePaniers: 1, familialPaniers: 2, fruitPaniers: 1, eggPaniers: 2, panier: [],),
    Center(child: Text('Profil', style: TextStyle(fontSize: 24))),
    Center(child: Text('Tour', style: TextStyle(fontSize: 24))),
    QrScreen(), // Ajoutez la page QR ici
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _pages[_selectedIndex], // Page correspondante
          Align(
            alignment: Alignment.bottomCenter,
            child: BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
                BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Panier'),
                BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
                BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Tour'),
                BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: 'QR'),
              ],
              currentIndex: _selectedIndex, // Indicateur de page active
              selectedItemColor: Colors.green,
              onTap: _onItemTapped,  // Fonction pour changer de page
              type: BottomNavigationBarType.fixed,
            ),
          ),
        ],
      ),
    );
  }
}

class SubscriptionScreen extends StatefulWidget {
  @override
  _SubscriptionScreenState createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  List<model.DeliveryPoint> _subscriptions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSubscriptions();
  }

  Future<void> _fetchSubscriptions() async {
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

        List<model.DeliveryPoint> deliveryPoints = data
          .where((json) => json['adresses'] != null)
          .map((json) => model.DeliveryPoint.fromJson(json))
          .toList();

        // Utiliser un Set pour éliminer les doublons
        Set<model.DeliveryPoint> uniqueDeliveryPoints = deliveryPoints.toSet();

        setState(() {
          _subscriptions = uniqueDeliveryPoints.toList();
          _isLoading = false;
        });
      } else {
        print("Erreur API: ${response.statusCode}");
        print("Response: ${response.body}");
      }
    } catch (e) {
      print("Erreur lors du chargement des abonnements: $e");
    }
  }

  void _onTourneeSelected(BuildContext context, model.DeliveryPoint tournee) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => screen.TourMapScreen(
          deliveryPoint: tournee, 
          selectedDay: '',
          depotId: tournee.depotId.toString(),
          depot: tournee.depot,
          quantity: tournee.quantity.toString(),
          address: tournee.address,
          postalCode: tournee.postalCode,
          city: tournee.city,
          location: tournee.location.toString(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Choisissez une tournée')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _subscriptions.length,
              itemBuilder: (context, index) {
                final plan = _subscriptions[index];
                return GestureDetector(
                  onTap: () => _onTourneeSelected(context, plan),
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.greenAccent,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      title: Text(
                        plan.depot,
                        style: TextStyle(
                          fontSize: 24, 
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      subtitle: Text(
                        '${plan.quantity} unités\n${plan.address}, ${plan.postalCode} ${plan.city}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}