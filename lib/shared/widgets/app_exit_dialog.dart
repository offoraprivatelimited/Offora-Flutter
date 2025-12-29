import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

/// Dialog shown when user tries to navigate back from dashboard
/// This prevents accidental logout and provides a friendly exit experience
class AppExitDialog extends StatelessWidget {
  final String? userRole; // 'user' or 'shopowner'
  final bool
      isExiting; // true if user is exiting the app, false if just navigating back

  const AppExitDialog({
    super.key,
    this.userRole,
    this.isExiting = false,
  });

  String get _title {
    return isExiting ? 'Exit Offora?' : 'Leave Dashboard?';
  }

  String get _message {
    if (isExiting) {
      return 'You are about to exit Offora.\n\nYou will need to log in again if you want to return.';
    }
    return 'You are about to log out from your dashboard.\n\nTo access your dashboard again, you will need to log in.';
  }

  String get _stayButtonLabel {
    return isExiting ? 'Stay in App' : 'Stay in Dashboard';
  }

  String get _exitButtonLabel {
    return isExiting ? 'Exit Offora' : 'Log Out';
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.grey[900] : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return AlertDialog(
      backgroundColor: backgroundColor,
      title: Text(
        _title,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      content: Text(
        _message,
        style: TextStyle(
          color: textColor,
          fontSize: 16,
          height: 1.5,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: Text(
            _stayButtonLabel,
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: Text(
            _exitButtonLabel,
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      contentPadding: const EdgeInsets.all(24),
    );
  }

  /// Show exit/logout warning dialog and handle logout if confirmed
  static Future<bool> show(
    BuildContext context, {
    String? userRole,
    bool isExiting = false,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AppExitDialog(
        userRole: userRole,
        isExiting: isExiting,
      ),
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
