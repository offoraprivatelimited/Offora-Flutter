import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          ListTile(
            leading: Icon(Icons.local_offer),
            title: Text('New: 40% off at Moda Boutique'),
            subtitle: Text('Expires in 3 days'),
          ),
          ListTile(
            leading: Icon(Icons.warning),
            title: Text('Expiring soon: Organic Vegetables'),
            subtitle: Text('Expires tomorrow'),
          ),
        ],
      ),
    );
  }
}
