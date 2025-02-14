import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_application_2/screens/tour_map.dart';
import 'cday.dart';  // Assure-toi d'avoir la page Cday importée
import 'qr_screen.dart';
import 'panier.screen.dart';

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
    PanierScreen( // Redirection vers la page PanierScreen
      simplePaniers: 2,
      familialPaniers: 3,
      fruitPaniers: 2,
      eggPaniers: 1,
    ),
    Center(child: Text('Profil', style: TextStyle(fontSize: 24))),
    DayPickerPage(), // Redirection vers la page Cday
    QrScreen(),
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
                BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Tour'),  // "Tour" icône
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

class SubscriptionScreen extends StatelessWidget {
  final List<String> subscriptions = [
    'Epinal',
    'Tournée 2',
    'Tournée 3',
  ];

  void _onTourneeSelected(BuildContext context, String tournee) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TourMapScreen(selectedDay: tournee),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Choisissez votre abonnement')),
      body: Column(
        children: [
          CarouselSlider(
            options: CarouselOptions(height: 200, autoPlay: true),
            items: subscriptions.map((plan) {
              return Builder(
                builder: (BuildContext context) {
                  return GestureDetector(
                    onTap: () => _onTourneeSelected(context, plan),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.symmetric(horizontal: 5.0),
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
                      child: Center(
                        child: Text(
                          plan,
                          style: TextStyle(
                            fontSize: 24, 
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}