import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/auth_service.dart';
import '../../../models/client_panel_stage.dart';
import '../auth/login_screen.dart';
import '../dashboard/dashboard_screen.dart';

class ClientSplashScreen extends StatefulWidget {
  const ClientSplashScreen({super.key});

  static const String routeName = '/client-splash';

  @override
  State<ClientSplashScreen> createState() => _ClientSplashScreenState();
}

class _ClientSplashScreenState extends State<ClientSplashScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _maybeRedirect();
  }

  void _maybeRedirect() {
    final auth = context.read<AuthService>();
    // If not logged in, go to login. Otherwise, go to dashboard.
    final String route = auth.stage == ClientPanelStage.active
        ? DashboardScreen.routeName
        : LoginScreen.routeName;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(route);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Preparing your workspace...'),
          ],
        ),
      ),
    );
  }
}
