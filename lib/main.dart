import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sae_cocagne_mobile/client.dart';
import 'package:sae_cocagne_mobile/delivery/app_state.dart';
import 'package:sae_cocagne_mobile/delivery/delivery.dart';

void main() {
  runApp(
    ChangeNotifierProvider<AppState>(
      create: (context) => AppState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jardins de Cocagne',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green),
          bodyLarge: TextStyle(fontSize: 18, color: Colors.black87),
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green[100]!, Colors.green[300]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Bienvenue aux Jardins de Cocagne',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              _buildButton(
                context: context,
                icon: Icons.local_shipping,
                label: 'Livreur',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DeliveryPage()),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildButton(
                context: context,
                icon: Icons.person,
                label: 'Client',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ClientScreen(message: '',)),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton({required BuildContext context, required IconData icon, required String label, required VoidCallback onPressed}) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 28, color: Colors.white),
      label: Text(label, style: const TextStyle(fontSize: 20, color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green[700],
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 10,
        shadowColor: Colors.green[900],
      ),
    );
  }
}