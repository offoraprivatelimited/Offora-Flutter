import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

/// Dialog shown when user tries to navigate back from dashboard
/// This prevents accidental logout and only allows logout through the profile screen or drawer
class LogoutWarningDialog extends StatelessWidget {
  const LogoutWarningDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Back Navigation',
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      content: const Text(
        'Are you sure you want to go back? You will be logged out.\n\nTo stay logged in, use the Sign Out button in your Profile or the app drawer.',
        style: TextStyle(color: Colors.black),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text(
            'Stay',
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text(
            'Logout',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  /// Show logout warning dialog and handle logout if confirmed
  static Future<bool> show(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const LogoutWarningDialog(),
    );

    if (confirmed == true && context.mounted) {
      try {
        await context.read<AuthService>().signOut();
        if (context.mounted) {
          context.go('/role-selection');
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error logging out: $e')),
          );
        }
      }
      return true;
    }
    return false;
  }
}
