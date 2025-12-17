import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../services/auth_service.dart';
import '../../../models/client_panel_stage.dart';

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
    final String routeName = auth.stage == ClientPanelStage.active
        ? 'client-dashboard'
        : 'client-login';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.goNamed(routeName);
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
