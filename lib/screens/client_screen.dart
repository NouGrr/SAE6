import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';

class ClientScreen extends StatelessWidget {
  late final String message;
    ClientScreen({required this.message});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Client'),
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          return Column(
            children: [
              if (appState.isQrScanned)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'QR code scanné!',
                    style: TextStyle(color: Colors.green, fontSize: 18),
                  ),
                ),
              if (appState.isQrScanned)
                Expanded(
                  child: ListView(
                    children: [
                      ListTile(
                        leading: Icon(Icons.check_circle, color: Colors.green),
                        title: Text('QR code du dépôt scanné'),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}