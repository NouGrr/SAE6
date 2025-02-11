import 'package:flutter/material.dart';
import 'package:flutter_application_2/screens/liv_screen.dart';
import 'livreur_screen.dart';
import 'package:flutter_application_2/screens/livreur_screen.dart';
import 'client_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Choisir un rôle')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              },
              child: Text('Livreur'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ClientScreen()),
                );
              },
              child: Text('Client'),
            ),
          ],
        ),
      ),
    );
  }
}

