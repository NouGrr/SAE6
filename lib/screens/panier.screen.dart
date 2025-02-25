import 'package:flutter/material.dart';

class PanierScreen extends StatelessWidget {
  final int simplePaniers;
  final int familialPaniers;
  final int fruitPaniers;
  final int eggPaniers;
  final List<String> panier;
  final VoidCallback onContinue;

  const PanierScreen({
    Key? key,
    required this.simplePaniers,
    required this.familialPaniers,
    required this.fruitPaniers,
    required this.eggPaniers,
    required this.panier,
    required this.onContinue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails du panier'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contenu du panier',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 20),
            _buildPanierItem('Panier Simple', simplePaniers, Icons.shopping_basket),
            _buildPanierItem('Panier Familial', familialPaniers, Icons.shopping_bag),
            _buildPanierItem('Panier Fruits', fruitPaniers, Icons.apple),
            _buildPanierItem("Boîte d'œufs", eggPaniers, Icons.egg),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: onContinue,
        label: Text('Voir sur la carte'),
        icon: Icon(Icons.map),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildPanierItem(String name, int quantity, IconData icon) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.green),
        title: Text(
          name,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'x$quantity',
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}