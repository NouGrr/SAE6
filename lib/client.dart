import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'delivery/app_state.dart';
import 'delivery/profile.dart';

class ClientScreen extends StatelessWidget {
  final String message;
  ClientScreen({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Détails de la livraison',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.normal,
          ),
        ),
        backgroundColor: Colors.green,
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          return SingleChildScrollView(
            child: Column(
              children: [
                if (appState.isQrScanned)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
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
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping),
            label: 'Livraisons',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfilePage(),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildPanierDetails() {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(Icons.place, color: Colors.green),
              title: Text(
                'Dépôt : ${appState.depotName}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500
                ),
              ),
              subtitle: Text(
                appState.message,
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w500
                ),
              ),
            ),
            Divider(),
            Text(
              'État de la livraison',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green
              ),
            ),
            SizedBox(height: 10),
            ListTile(
              leading: Icon(Icons.check_circle, color: Colors.green),
              title: Text('Panier déposé'),
              subtitle: Text('Scan QR Code validé'),
              trailing: Icon(Icons.done_all, color: Colors.green),
            ),
          ],
        );
      },
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