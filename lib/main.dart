import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_strategy/url_strategy.dart';

import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'services/auth_service.dart';
import 'services/saved_offers_service.dart';
import 'services/compare_service.dart';
import 'client/services/offer_service.dart';
import 'widgets/responsive_wrapper.dart';
import 'core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setPathUrlStrategy();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Enable persistence for web to maintain authentication state
  if (Firebase.apps.isNotEmpty) {
    try {
      await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
    } catch (e) {
      if (kDebugMode) print('Error setting persistence: $e');
    }
  }
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
      child: MaterialApp.router(
        // Wrap app content to provide desktop/tablet centering and padding
        builder: (context, child) =>
            ResponsiveApp(child: child ?? const SizedBox.shrink()),
        title: 'Offora',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
