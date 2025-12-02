import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

class _UserSplashScreenState extends State<UserSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Setup animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _animationController.forward();

    // Navigate after delay
    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      final authService = Provider.of<AuthService>(context, listen: false);

      if (authService.isLoggedIn && authService.currentUser != null) {
        final user = authService.currentUser!;
        if (!user.isProfileComplete) {
          Navigator.pushReplacementNamed(
              context, ProfileCompleteScreen.routeName);
        } else {
          Navigator.pushReplacementNamed(context, MainScreen.routeName);
        }
      } else {
        Navigator.pushReplacementNamed(context, OnboardingScreen.routeName);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const darkBlue = Color(0xFF1F477D);

    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(builder: (context, constraints) {
        return Stack(
          children: [
            // Decorative background circles
            Positioned(
              top: -constraints.maxWidth * 0.15,
              right: -constraints.maxWidth * 0.25,
              child: Container(
                width: constraints.maxWidth * 0.7,
                height: constraints.maxWidth * 0.7,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Color(0xE6F0B84D), // brightGold @ 0.9
                      Color(0x4CF0B84D), // brightGold @ 0.3
                    ],
                    center: Alignment.topRight,
                    radius: 0.9,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -constraints.maxWidth * 0.2,
              left: -constraints.maxWidth * 0.15,
              child: Container(
                width: constraints.maxWidth * 0.8,
                height: constraints.maxWidth * 0.8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Color(0xCC1F477D), // darkBlue @ 0.8
                      Color(0x331F477D), // darkBlue @ 0.2
                    ],
                    center: Alignment.bottomLeft,
                    radius: 0.9,
                  ),
                ),
              ),
            ),
            // Main content
            Center(
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      Container(
                        width: 140,
                        height: 140,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x66A3834D), // darkerGold @ 0.4
                              blurRadius: 30,
                              offset: Offset(0, 15),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/logo/original/Logo_without_text_without_background.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Brand text
                      const Text(
                        'Offora',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: darkBlue,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'The Offer World',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
