import 'package:flutter/material.dart';
import 'package:flutter_application_2/screens/panierdetail_screen.dart';
import 'panierdetail_screen.dart';

class PanierScreen extends StatelessWidget {
  final int simplePaniers;
  final int familialPaniers;
  final int fruitPaniers;
  final int eggPaniers;

  PanierScreen({
    required this.simplePaniers,
    required this.familialPaniers,
    required this.fruitPaniers,
    required this.eggPaniers,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Paniers à Livrer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPanierCard(
              context,
              'Paniers Simples',
              simplePaniers,
              Icons.shopping_basket,
              Colors.blue,
            ),
            SizedBox(height: 16),
            _buildPanierCard(
              context,
              'Paniers Familiaux',
              familialPaniers,
              Icons.family_restroom,
              Colors.green,
            ),
            SizedBox(height: 16),
            _buildPanierCard(
              context,
              'Paniers de Fruits',
              fruitPaniers,
              Icons.local_florist,
              Colors.orange,
            ),
            SizedBox(height: 16),
            _buildPanierCard(
              context,
              'Paniers d\'œufs',
              eggPaniers,
              Icons.egg,
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPanierCard(BuildContext context, String title, int count, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PanierDetailScreen(
              title: title,
              count: count,
              icon: icon,
              color: color,
            ),
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: color),
              SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Nombre: $count',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}