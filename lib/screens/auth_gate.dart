import 'package:flutter/material.dart';
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
        // Show loading while checking auth state
        if (authService.isBusy) {
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
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacementNamed(MainScreen.routeName);
            });
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // Shop owner - check approval stage
          if (authService.stage == ClientPanelStage.active) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context)
                  .pushReplacementNamed(ClientMainScreen.routeName);
            });
          } else if (authService.stage == ClientPanelStage.pendingApproval) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context)
                  .pushReplacementNamed(PendingApprovalPage.routeName);
            });
          } else if (authService.stage == ClientPanelStage.rejected) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context)
                  .pushReplacementNamed(RejectionPage.routeName);
            });
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
}
