import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _dark = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SwitchListTile(
            title: const Text('Dark mode'),
            value: _dark,
            onChanged: (v) => setState(() => _dark = v),
          ),
          const ListTile(
            title: Text('About Us'),
            subtitle: Text('Offora - All offers in one place'),
          ),
          const ListTile(
            title: Text('Contact Support'),
            subtitle: Text('support@offora.example'),
          ),
        ],
      ),
    );
  }
}
