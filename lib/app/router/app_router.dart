import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:offora/features/auth/screens/auth_gate.dart';
import 'package:offora/features/auth/screens/role_selection_screen.dart';
import 'package:offora/features/user/screens/splash_screen.dart' as user;
import 'package:offora/features/user/screens/onboarding_screen.dart';
import 'package:offora/features/auth/screens/auth_screen.dart';
import 'package:offora/features/user/screens/main_screen.dart';
import 'package:offora/features/user/screens/offer_details_screen.dart';
import 'package:offora/features/user/screens/profile_complete_screen.dart';
import 'package:offora/features/user/screens/user_login_screen.dart';
import 'package:offora/shared/widgets/about_us_page.dart';
import 'package:offora/shared/widgets/contact_us_page.dart';
import 'package:offora/shared/widgets/terms_and_conditions_page.dart';
import 'package:offora/shared/widgets/privacy_policy_page.dart';
import 'package:offora/features/user/screens/notifications_screen.dart';
import 'package:offora/features/user/screens/settings_screen.dart';
import 'package:offora/shared/widgets/info_page_wrapper.dart';
import 'package:offora/features/client/screens/auth/login_screen.dart'
    as client;
import 'package:offora/features/client/screens/auth/signup_screen.dart'
    as client;
import 'package:offora/features/client/screens/auth/pending_approval_page.dart'
    as client;
import 'package:offora/features/client/screens/auth/rejection_page.dart'
    as client;
import 'package:offora/features/client/screens/main/client_main_screen.dart'
    as client;
import 'package:offora/features/client/screens/dashboard/manage_offers_screen.dart'
    as client;
import 'package:offora/features/client/screens/offers/new_offer_form_screen.dart'
    as client;

class AppRouter {
  // User routes
  static const String home = '/home';
  static const String homeExplore = '/explore';
  static const String homeCompare = '/compare';
  static const String homeSaved = '/saved';
  static const String homeProfile = '/profile';
  static const String offerDetails = '/offer-details';
  static const String notifications = '/notifications';
  static const String settings = '/settings';
  static const String advertisementDetails = '/advertisement-details';

  // Client routes
  static const String clientDashboard = '/client-dashboard';
  static const String clientAdd = '/client-add';
  static const String clientManage = '/client-manage';
  static const String clientEnquiries = '/client-enquiries';
  static const String clientProfile = '/client-profile';

  // Info pages
  static const String aboutUs = '/about-us';
  static const String contactUs = '/contact-us';
  static const String termsAndConditions = '/terms-and-conditions';
  static const String privacyPolicy = '/privacy-policy';

  // Auth routes
  static const String authGate = '/';
  static const String roleSelection = '/role-selection';
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String auth = '/auth';
  static const String userLogin = '/user-login';
  static const String profileComplete = '/profile-complete';
  static const String clientLogin = '/client-login';
  static const String clientSignup = '/client-signup';
  static const String pendingApproval = '/pending-approval';
  static const String rejection = '/rejection';

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    // Simple error handler - just show error page
    errorBuilder: (context, state) {
      final location = state.matchedLocation;

      // Firebase internal routes - return empty widget
      if (location.startsWith('/__/')) {
        return const SizedBox.shrink();
      }

      // Show simple error page for invalid routes
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Page not found',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => context.go('/'),
                icon: const Icon(Icons.home),
                label: const Text('Go to Home'),
              ),
            ],
          ),
        ),
      );
    },
    routes: [
      // ============ AUTH ROUTES ============
      // Initial loading screen - shown while checking auth state
      GoRoute(
        path: '/',
        name: 'auth-gate',
        builder: (context, state) => const AuthGate(),
      ),
      GoRoute(
        path: '/role-selection',
        name: 'role-selection',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const user.UserSplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/user-login',
        name: 'user-login',
        builder: (context, state) => const UserLoginScreen(),
      ),
      GoRoute(
        path: '/profile-complete',
        name: 'profile-complete',
        builder: (context, state) => const ProfileCompleteScreen(),
      ),

      // ============ USER ROUTES ============
      // Main app shell for logged in users - prevents back navigation to login
      ShellRoute(
        builder: (context, state, child) {
          // Return child directly - the child will be one of the MainScreen routes
          return child;
        },
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => const MainScreen(initialIndex: 0),
          ),
          GoRoute(
            path: '/explore',
            name: 'explore',
            builder: (context, state) => const MainScreen(initialIndex: 1),
          ),
          GoRoute(
            path: '/compare',
            name: 'compare',
            builder: (context, state) => const MainScreen(initialIndex: 2),
          ),
          GoRoute(
            path: '/saved',
            name: 'saved',
            builder: (context, state) => const MainScreen(initialIndex: 3),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const MainScreen(initialIndex: 4),
          ),
        ],
      ),
      GoRoute(
        path: '/offer-details',
        name: 'offer-details',
        builder: (context, state) => const OfferDetailsScreen(),
      ),
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/advertisement-details',
        name: 'advertisement-details',
        builder: (context, state) {
          // These parameters should be passed from previous route
          return const Scaffold(
            body: Center(child: Text('Advertisement Details')),
          );
        },
      ),

      // ============ CLIENT ROUTES ============
      // Client Auth Routes
      GoRoute(
        path: '/client-login',
        name: 'client-login',
        builder: (context, state) => const client.LoginScreen(),
      ),
      GoRoute(
        path: '/client-signup',
        name: 'client-signup',
        builder: (context, state) => const client.SignupScreen(),
      ),
      GoRoute(
        path: '/pending-approval',
        name: 'pending-approval',
        builder: (context, state) => const client.PendingApprovalPage(),
      ),
      GoRoute(
        path: '/rejection',
        name: 'rejection',
        builder: (context, state) => const client.RejectionPage(),
      ),

      // Client Dashboard Routes - use ShellRoute to prevent back to auth
      GoRoute(
        path: '/client-dashboard',
        name: 'client-dashboard',
        builder: (context, state) => const client.ClientMainScreen(
          initialIndex: 1,
        ),
      ),
      GoRoute(
        path: '/client-add',
        name: 'client-add',
        builder: (context, state) => const client.ClientMainScreen(
          initialIndex: 0,
        ),
      ),
      GoRoute(
        path: '/client-manage',
        name: 'client-manage',
        builder: (context, state) => const client.ClientMainScreen(
          initialIndex: 1,
        ),
      ),
      GoRoute(
        path: '/client-enquiries',
        name: 'client-enquiries',
        builder: (context, state) => const client.ClientMainScreen(
          initialIndex: 2,
        ),
      ),
      GoRoute(
        path: '/client-profile',
        name: 'client-profile',
        builder: (context, state) => const client.ClientMainScreen(
          initialIndex: 3,
        ),
      ),
      GoRoute(
        path: '/new-offer',
        name: 'new-offer',
        builder: (context, state) => const client.NewOfferFormScreen(),
      ),
      GoRoute(
        path: '/manage-offers',
        name: 'manage-offers',
        builder: (context, state) => const client.ManageOffersScreen(),
      ),

      // ============ INFO ROUTES ============
      GoRoute(
        path: '/about-us',
        name: 'about-us',
        builder: (context, state) => const InfoPageWrapper(
          title: 'About Us',
          child: AboutUsPage(),
        ),
      ),
      GoRoute(
        path: '/contact-us',
        name: 'contact-us',
        builder: (context, state) => const InfoPageWrapper(
          title: 'Contact Us',
          child: ContactUsPage(),
        ),
      ),
      GoRoute(
        path: '/terms-and-conditions',
        name: 'terms-and-conditions',
        builder: (context, state) => const InfoPageWrapper(
          title: 'Terms & Conditions',
          child: TermsAndConditionsPage(),
        ),
      ),
      GoRoute(
        path: '/privacy-policy',
        name: 'privacy-policy',
        builder: (context, state) => const InfoPageWrapper(
          title: 'Privacy Policy',
          child: PrivacyPolicyPage(),
        ),
      ),

      // ============ FIREBASE INTERNAL ROUTES ============
      // These routes are required for Firebase authentication on web
      // Firebase uses /__/auth/iframe and /__/auth/handler for Google Sign-In popup
      GoRoute(
        path: '/__/auth/iframe',
        name: 'firebase-auth-iframe',
        builder: (context, state) => const SizedBox.shrink(),
      ),
      GoRoute(
        path: '/__/auth/handler',
        name: 'firebase-auth-handler',
        builder: (context, state) => const SizedBox.shrink(),
      ),
    ],
  );

  /// List of all valid routes in the application
  static const List<String> validRoutes = [
    '/',
    '/home',
    '/explore',
    '/compare',
    '/saved',
    '/profile',
    '/role-selection',
    '/splash',
    '/onboarding',
    '/auth',
    '/user-login',
    '/profile-complete',
    '/offer-details',
    '/notifications',
    '/settings',
    '/advertisement-details',
    '/client-login',
    '/client-signup',
    '/pending-approval',
    '/rejection',
    '/client-dashboard',
    '/client-add',
    '/client-manage',
    '/client-enquiries',
    '/client-profile',
    '/new-offer',
    '/manage-offers',
    '/about-us',
    '/contact-us',
    '/terms-and-conditions',
    '/privacy-policy',
    '/__/auth/iframe', // Firebase authentication iframe
    '/__/auth/handler', // Firebase authentication handler
  ];

  /// Check if a route path is valid
  static bool isValidRoute(String path) {
    // Allow any Firebase internal routes
    if (path.startsWith('/__/')) {
      return true;
    }
    return validRoutes
        .any((route) => path == route || path.startsWith('$route/'));
  }

  /// This prevents back button from returning to logged-in screens
  static void clearAndNavigateToRoleSelection(BuildContext context) {
    // Clear entire navigation history by using go instead of push
    context.go('/role-selection');
  }

  /// Clear the entire navigation stack and go to home after login
  /// This prevents back button from returning to login screens
  static void clearAndNavigateToHome(BuildContext context) {
    context.go('/home');
  }

  /// Clear the entire navigation stack and go to client dashboard after login
  /// This prevents back button from returning to login screens
  static void clearAndNavigateToClientDashboard(BuildContext context) {
    context.go('/client-dashboard');
  }
}
