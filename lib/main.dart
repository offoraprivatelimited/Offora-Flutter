import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/main_screen.dart';
import 'screens/offer_details_screen.dart';

void main() {
  runApp(const OfforaApp());
}

class OfforaApp extends StatelessWidget {
  const OfforaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Offora',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (_) => const SplashScreen(),
        OnboardingScreen.routeName: (_) => const OnboardingScreen(),
        AuthScreen.routeName: (_) => const AuthScreen(),
        MainScreen.routeName: (_) => const MainScreen(),
        OfferDetailsScreen.routeName: (_) => const OfferDetailsScreen(),
      },
    );
  }
}
