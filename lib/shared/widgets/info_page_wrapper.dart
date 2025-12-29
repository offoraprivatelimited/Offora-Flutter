import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class InfoPageWrapper extends StatelessWidget {
  final Widget child;
  final String title;

  const InfoPageWrapper({
    super.key,
    required this.child,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    // Watch auth service to get real-time user role updates
    final auth = context.watch<AuthService>();
    final currentUser = auth.currentUser;
    final isClient = currentUser?.role == 'shopowner';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                // Go back to appropriate dashboard based on current user role
                if (isClient) {
                  context.goNamed('client-dashboard');
                } else {
                  context.goNamed('home');
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: const Icon(Icons.arrow_back, color: Colors.black),
            ),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: child,
    );
  }
}
