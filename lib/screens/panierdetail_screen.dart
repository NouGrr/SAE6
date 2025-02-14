import 'package:flutter/material.dart';

class PanierDetailScreen extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;

  const PanierDetailScreen({
    Key? key,
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
  }) : super(key: key);

  List<String> _getDetails(String title) {
    switch (title) {
      case 'Paniers Simples':
        return ['Carottes', 'Oignons', 'Salade', 'Haricots'];
      case 'Paniers de Fruits':
        return ['Pommes', 'Poires', 'Oranges', 'Fraises', 'Clémentines', 'Bananes'];
      case 'Paniers d\'œufs':
        return ['Œufs élevés en plein air'];
      case 'Paniers Familiaux':
        return ['Œufs', 'Pommes', 'Oranges', 'Citrons', 'Oignons', 'Haricots', 'Bananes'];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> details = _getDetails(title);

    return Scaffold(
      appBar: AppBar(
        title: Text('$title Détails'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 40, color: color),
                SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Nombre: $count',
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Détails des produits :',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            ...details.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                item,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}