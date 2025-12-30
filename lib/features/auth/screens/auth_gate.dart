import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../shared/services/auth_service.dart';
import '../../../shared/models/client_panel_stage.dart';
import '../../../app/router/app_router.dart';
import '../../user/screens/splash_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  static const String routeName = '/auth-gate';

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, _) {
        // CRITICAL: Wait for initial auth check to complete
        if (!authService.initialCheckComplete) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading Offora...'),
                ],
              ),
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
              AppRouter.home,
            );
          }

          // Shop owner - check approval stage
          if (authService.stage == ClientPanelStage.active) {
            return _buildTransitionScreen(
              context,
              AppRouter.clientDashboard,
            );
          } else if (authService.stage == ClientPanelStage.pendingApproval) {
            return _buildTransitionScreen(
              context,
              AppRouter.pendingApproval,
            );
          } else if (authService.stage == ClientPanelStage.rejected) {
            return _buildTransitionScreen(
              context,
              AppRouter.rejection,
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
      // Safely check context is still mounted before navigating
      if (context.mounted) {
        // Use go() to replace the route and clear navigation stack
        // This prevents back button from returning to auth screens
        context.go(routeName);
      }
    });

    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
