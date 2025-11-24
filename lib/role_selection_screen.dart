import 'package:flutter/material.dart';
import 'client/screens/auth/login_screen.dart' as client;

class RoleSelectionScreen extends StatelessWidget {
  static const String routeName = '/role-selection';

  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Role')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(
                  context,
                  '/user-login',
                );
              },
              child: const Text('Continue as User'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(
                  context,
                  client.LoginScreen.routeName,
                  arguments: {'role': 'shopowner'},
                );
              },
              child: const Text('Continue as Shopowner'),
            ),
          ],
        ),
      ),
    );
  }
}
