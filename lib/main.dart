import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/app_state.dart';
import 'qr_scanner_service.dart';
import 'screens/client_screen.dart';
import 'screens/liv_screen.dart'; // Importez votre fichier liv_screen.dart


void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Code Scanner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Accueil'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(), // Naviguez vers LivScreen
                  ),
                );
              },
              child: Text('Livreur'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ClientScreen(),
                  ),
                );
              },
              child: Text('Page Client'),
            ),
          ],
        ),
      ),
    );
  }
}