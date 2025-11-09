import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';

import 'theme/app_theme.dart';
import 'services/auth_service.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/main_screen.dart';
import 'screens/offer_details_screen.dart';
import 'screens/profile_complete_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const OfforaApp());
}

class OfforaApp extends StatelessWidget {
  const OfforaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthService(),
      child: MaterialApp(
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
          ProfileCompleteScreen.routeName: (_) => const ProfileCompleteScreen(),
        },
      ),
    );
  }
}
