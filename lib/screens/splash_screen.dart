import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../services/auth_service.dart';
import 'onboarding_screen.dart';
import 'profile_complete_screen.dart';
import 'main_screen.dart';

class UserSplashScreen extends StatefulWidget {
  static const String routeName = '/user-splash';
  const UserSplashScreen({super.key});

  @override
  State<UserSplashScreen> createState() => _UserSplashScreenState();
}

class _UserSplashScreenState extends State<UserSplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      final authService = Provider.of<AuthService>(context, listen: false);

      if (authService.isLoggedIn && authService.currentUser != null) {
        final user = authService.currentUser!;
        // User is logged in, check if profile is complete
        if (user.address.isEmpty || user.gender.isEmpty || user.dob.isEmpty) {
          // Profile is incomplete
          Navigator.pushReplacementNamed(
              context, ProfileCompleteScreen.routeName);
        } else {
          // Profile is complete
          Navigator.pushReplacementNamed(context, MainScreen.routeName);
        }
      } else {
        // Not logged in, show onboarding
        Navigator.pushReplacementNamed(context, OnboardingScreen.routeName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.local_offer, color: Colors.white, size: 86),
              SizedBox(height: 16),
              Text(
                'Offora',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
