import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';

class ClientScreen extends StatelessWidget {
  final String message;
  ClientScreen({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails de la livraison'),
        backgroundColor: Colors.green,
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          return Column(
            children: [
              if (appState.isQrScanned)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle, color: Colors.green, size: 30),
                              SizedBox(width: 10),
                              Text(
                                'QR Code scanné avec succès !',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.green, size: 30),
                              SizedBox(width: 10),
                              Text(
                                'Détails du panier',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          _buildPanierDetails(),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPanierDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPanierItem('Panier Simple', '2', Icons.shopping_basket),
        _buildPanierItem('Panier Familial', '1', Icons.shopping_bag),
        _buildPanierItem('Panier Fruits', '1', Icons.apple),
        _buildPanierItem("Boîte d'œufs", '2', Icons.egg),
        SizedBox(height: 10),
        Divider(),
        SizedBox(height: 10),
        Text(
          'Dépôt : ${message}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500
          ),
        ),
      ],
    );
  }

  Widget _buildPanierItem(String name, String quantity, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.green),
          SizedBox(width: 10),
          Text(
            name,
            style: TextStyle(fontSize: 16),
          ),
          Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'x$quantity',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold
              ),
            ),
          ),
        ],
      ),
    );
  }
}