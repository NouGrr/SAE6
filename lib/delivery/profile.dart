import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profil',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.normal,
          ),
        ),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(height: 20),
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.green.shade100,
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Ewan Urbanc',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 40),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.email, color: Colors.green),
                      title: Text('Email'),
                      subtitle: Text('ewan.urbanc@example.com'),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.phone, color: Colors.green),
                      title: Text('Téléphone'),
                      subtitle: Text('+33 6 12 34 56 78'),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.location_on, color: Colors.green),
                      title: Text('Adresse'),
                      subtitle: Text('70 rue Pierre Evrat, 88100 Saint-Dié-des-Vosges'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber),
                          SizedBox(width: 8),
                          Text(
                            'Abonnement Premium',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 0),
                    ListTile(
                      leading: Icon(Icons.attach_money, color: Colors.green),
                      title: Text('Prix mensuel'),
                      subtitle: Text('29,99 €'),
                    ),
                    Divider(height: 0),
                    ListTile(
                      leading: Icon(Icons.calendar_today, color: Colors.green),
                      title: Text('Prochaine facturation'),
                      subtitle: Text('15 mars 2024'),
                    ),
                    Divider(height: 0),
                    ListTile(
                      leading: Icon(Icons.local_shipping, color: Colors.green),
                      title: Text('Livraisons incluses'),
                      subtitle: Text('Illimitées'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
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
          if (index == 0) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}