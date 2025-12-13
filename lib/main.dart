import 'screens/about_us_page.dart';
import 'screens/contact_us_page.dart';
import 'screens/terms_and_conditions_page.dart';
import 'screens/privacy_policy_page.dart';
import 'screens/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'package:url_strategy/url_strategy.dart';

import 'theme/app_theme.dart';
import 'services/auth_service.dart';
import 'services/saved_offers_service.dart';
import 'services/compare_service.dart';
import 'client/services/offer_service.dart';
import 'screens/splash_screen.dart' as user;
import 'screens/onboarding_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/main_screen.dart';
import 'screens/offer_details_screen.dart';
import 'screens/profile_complete_screen.dart';
import 'role_selection_screen.dart';
import 'client/screens/auth/login_screen.dart' as client;
import 'client/screens/auth/signup_screen.dart' as client;
import 'client/screens/auth/pending_approval_page.dart' as client;
import 'client/screens/auth/rejection_page.dart' as client;
import 'client/screens/dashboard/dashboard_screen.dart' as client;
import 'client/screens/main/client_main_screen.dart' as client;
import 'screens/user_login_screen.dart';
import 'client/screens/offers/new_offer_form_screen.dart' as client;
import 'client/screens/dashboard/manage_offers_screen.dart' as client;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setPathUrlStrategy();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const OfforaApp());
}

class OfforaApp extends StatelessWidget {
  const OfforaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => CompareService()),
        Provider(create: (_) => OfferService()),
        Provider(create: (_) => SavedOffersService()),
      ],
      child: MaterialApp(
        title: 'Offora',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        initialRoute: AuthGate.routeName,
        routes: {
          // Auth gate - checks persistent login
          AuthGate.routeName: (_) => const AuthGate(),
          // Entry point
          RoleSelectionScreen.routeName: (_) => const RoleSelectionScreen(),
          // User flow
          user.UserSplashScreen.routeName: (_) => const user.UserSplashScreen(),
          OnboardingScreen.routeName: (_) => const OnboardingScreen(),
          AuthScreen.routeName: (_) => const AuthScreen(),
          MainScreen.routeName: (_) => MainScreen(key: MainScreen.globalKey),
          OfferDetailsScreen.routeName: (_) => const OfferDetailsScreen(),
          ProfileCompleteScreen.routeName: (_) => const ProfileCompleteScreen(),
          // Shopowner (client) flow
          client.LoginScreen.routeName: (_) => const client.LoginScreen(),
          client.SignupScreen.routeName: (_) => const client.SignupScreen(),
          client.PendingApprovalPage.routeName: (_) =>
              const client.PendingApprovalPage(),
          client.RejectionPage.routeName: (_) => const client.RejectionPage(),
          client.DashboardScreen.routeName: (_) =>
              const client.ClientMainScreen(),
          client.ClientMainScreen.routeName: (_) =>
              const client.ClientMainScreen(),
          client.NewOfferFormScreen.routeName: (_) =>
              const client.NewOfferFormScreen(),
          client.ManageOffersScreen.routeName: (_) =>
              const client.ManageOffersScreen(),
          UserLoginScreen.routeName: (context) => const UserLoginScreen(),
          '/about-us': (_) => const AboutUsPage(),
          '/contact-us': (_) => const ContactUsPage(),
          '/terms-and-conditions': (_) => const TermsAndConditionsPage(),
          '/privacy-policy': (_) => const PrivacyPolicyPage(),
        },
        onGenerateRoute: (settings) {
          // Redirect to appropriate dashboard based on logged-in user role
          return MaterialPageRoute(
            builder: (context) {
              final auth = Provider.of<AuthService>(context, listen: false);
              final user = auth.currentUser;
              if (user != null && user.role == 'shopowner') {
                return const client.ClientMainScreen();
              } else if (user != null && user.role == 'user') {
                return MainScreen(key: MainScreen.globalKey);
              } else {
                // Not logged in, go to role selection
                return const RoleSelectionScreen();
              }
            },
            settings: settings,
          );
        },
        onUnknownRoute: (settings) {
          // Fallback for truly unknown routes, never show 404
          return MaterialPageRoute(
            builder: (context) {
              final auth = Provider.of<AuthService>(context, listen: false);
              final user = auth.currentUser;
              if (user != null && user.role == 'shopowner') {
                return const client.ClientMainScreen();
              } else if (user != null && user.role == 'user') {
                return MainScreen(key: MainScreen.globalKey);
              } else {
                // Not logged in, go to role selection
                return const RoleSelectionScreen();
              }
            },
            settings: settings,
          );
        },
      ),
    );
  }
}
