import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../models/client_panel_stage.dart';
import 'main_screen.dart';
import '../client/screens/main/client_main_screen.dart';
import '../client/screens/auth/pending_approval_page.dart';
import '../client/screens/auth/rejection_page.dart';
import 'splash_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  static const String routeName = '/auth-gate';

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, _) {
        // Wait for initial auth check to complete
        if (!authService.initialCheckComplete) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // If logged in, route based on user type
        if (authService.isLoggedIn && authService.currentUser != null) {
          final user = authService.currentUser!;

          // User (not shop owner)
          if (user.role == 'user') {
            return _buildTransitionScreen(
              context,
              MainScreen.routeName,
            );
          }

          // Shop owner - check approval stage
          if (authService.stage == ClientPanelStage.active) {
            return _buildTransitionScreen(
              context,
              ClientMainScreen.routeName,
            );
          } else if (authService.stage == ClientPanelStage.pendingApproval) {
            return _buildTransitionScreen(
              context,
              PendingApprovalPage.routeName,
            );
          } else if (authService.stage == ClientPanelStage.rejected) {
            return _buildTransitionScreen(
              context,
              RejectionPage.routeName,
            );
          }

          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Not logged in - show splash screen
        return const UserSplashScreen();
      },
    );
  }

  /// Build a screen that transitions to the target route once mounted
  Widget _buildTransitionScreen(BuildContext context, String routeName) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Use go() to replace the route and clear navigation stack
      // This prevents back button from returning to auth screens
      context.go(routeName);
    });

    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }

  bool get mounted => true;
}
