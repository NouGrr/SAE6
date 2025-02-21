import 'package:flutter/material.dart';
import 'tour_map.dart';
import '../models/delivery_point.dart' as model;

class DayPickerPage extends StatefulWidget {
  @override
  _DayPickerPageState createState() => _DayPickerPageState();
}

class _DayPickerPageState extends State<DayPickerPage> {
  String _selectedDay = 'Lundi'; // Jour par défaut

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choisir un Jour'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Sélectionnez un jour de la semaine:',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            DropdownButton<String>(
              value: _selectedDay,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedDay = newValue!;
                });
              },
              items: ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche']
                  .map<DropdownMenuItem<String>>((String day) {
                return DropdownMenuItem<String>(
                  value: day,
                  child: Text(day),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            Text(
              'Jour sélectionné: $_selectedDay',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigation vers la page de la carte avec le jour sélectionné
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TourMapScreen(
                      selectedDay: _selectedDay,
                      deliveryPoint: model.DeliveryPoint(
                        city: 'someDeliveryPoint',
                        depotId: 123, // Replace with an appropriate integer value
                        depot: 'someDepot',
                        quantity: 1.0,
                        address: 'someAddress',
                        postalCode: 'somePostalCode',
                        location: [0.0, 0.0], // Replace with appropriate latitude and longitude values
                        id: 'someId', tournee: 0,
                      ),
                      depotId: 'someDepotId',
                      depot: 'someDepot',
                      quantity: '1',
                      address: 'someAddress',
                      postalCode: 'somePostalCode',
                      city: 'someCity',
                      location: 'someLocation',
                    ),
                  ),
                );
              },
              child: Text('Voir l\'itinéraire'),
            ),
          ],
        ),
      ),
    );
  }
}
