import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:offora/screens/auth_gate.dart';
import 'package:offora/role_selection_screen.dart';
import 'package:offora/screens/splash_screen.dart' as user;
import 'package:offora/screens/onboarding_screen.dart';
import 'package:offora/screens/auth_screen.dart';
import 'package:offora/screens/main_screen.dart';
import 'package:offora/screens/offer_details_screen.dart';
import 'package:offora/screens/profile_complete_screen.dart';
import 'package:offora/screens/user_login_screen.dart';
import 'package:offora/screens/about_us_page.dart';
import 'package:offora/screens/contact_us_page.dart';
import 'package:offora/screens/terms_and_conditions_page.dart';
import 'package:offora/screens/privacy_policy_page.dart';
import 'package:offora/screens/notifications_screen.dart';
import 'package:offora/screens/settings_screen.dart';
import 'package:offora/widgets/info_page_wrapper.dart';
import 'package:offora/client/screens/auth/login_screen.dart' as client;
import 'package:offora/client/screens/auth/signup_screen.dart' as client;
import 'package:offora/client/screens/auth/pending_approval_page.dart'
    as client;
import 'package:offora/client/screens/auth/rejection_page.dart' as client;
import 'package:offora/client/screens/main/client_main_screen.dart' as client;
import 'package:offora/client/screens/dashboard/manage_offers_screen.dart'
    as client;
import 'package:offora/client/screens/offers/new_offer_form_screen.dart'
    as client;
import 'package:offora/services/auth_service.dart';

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
    // Custom handling for back button on the whole app
    redirect: _redirectLogic,
    errorBuilder: (context, state) {
      final auth = Provider.of<AuthService>(context, listen: false);

      // Debug logging
      // ignore: avoid_print
      print(
          '[GoRouter][errorBuilder] ERROR at ${state.matchedLocation}: ${state.error}');
      // ignore: avoid_print
      print(
          '[GoRouter][errorBuilder] Auth state: initialCheckComplete=${auth.initialCheckComplete}, isLoggedIn=${auth.isLoggedIn}');

      // CASE 1: Auth check still in progress - show loading
      if (!auth.initialCheckComplete) {
        // ignore: avoid_print
        print(
            '[GoRouter][errorBuilder] AUTH IN PROGRESS - showing loading screen');
        return const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading app...'),
              ],
            ),
          ),
        );
      }

      // CASE 2: User is logged in - NEVER show error page, redirect to dashboard
      if (auth.isLoggedIn && auth.currentUser != null) {
        // ignore: avoid_print
        print(
            '[GoRouter][errorBuilder] LOGGED-IN USER AT INVALID ROUTE - redirecting');
        // Schedule redirect to avoid build-time issues
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final route = auth.currentUser!.role == 'shopowner'
              ? '/client-dashboard'
              : '/home';
          context.go(route);
        });
        // Show loading while redirecting
        return const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Redirecting to dashboard...'),
              ],
            ),
          ),
        );
      }

      // CASE 3: User not logged in and accessing invalid route - show error
      // ignore: avoid_print
      print(
          '[GoRouter][errorBuilder] INVALID ROUTE FOR ANONYMOUS USER - showing error');
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
        redirect: _redirectLogic,
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
        redirect: (context, state) {
          // If user is already logged in, redirect to home instead of showing login screen
          final auth = Provider.of<AuthService>(context, listen: false);
          if (auth.isLoggedIn) {
            return '/home';
          }
          return null;
        },
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
        redirect: (context, state) {
          // If user is already logged in as shop owner, redirect to appropriate dashboard
          final auth = Provider.of<AuthService>(context, listen: false);
          if (auth.isLoggedIn && auth.currentUser?.role == 'shopowner') {
            return '/client-dashboard';
          }
          return null;
        },
        builder: (context, state) => const client.LoginScreen(),
      ),
      GoRoute(
        path: '/client-signup',
        name: 'client-signup',
        redirect: (context, state) {
          // If user is already logged in as shop owner, redirect to appropriate dashboard
          final auth = Provider.of<AuthService>(context, listen: false);
          if (auth.isLoggedIn && auth.currentUser?.role == 'shopowner') {
            return '/client-dashboard';
          }
          return null;
        },
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
    ],
  );

  static String? _redirectLogic(BuildContext context, GoRouterState state) {
    final auth = Provider.of<AuthService>(context, listen: false);
    final user = auth.currentUser;
    final location = state.matchedLocation;

    // Debug logging
    // ignore: avoid_print
    print(
        '[GoRouter][_redirectLogic] location=$location, initialCheckComplete=${auth.initialCheckComplete}, isLoggedIn=${auth.isLoggedIn}, userRole=${user?.role}');

    // PHASE 1: Auth check not complete - show loading
    if (!auth.initialCheckComplete) {
      // ignore: avoid_print
      print('[GoRouter][_redirectLogic] AUTH CHECK IN PROGRESS - waiting');
      return null; // Stay on current route (AuthGate will show loading)
    }

    // PHASE 2: Auth check complete
    // Validate route - if invalid and user is logged in, redirect to dashboard
    if (!isValidRoute(location)) {
      if (user != null) {
        // User is logged in but accessing invalid route - redirect to dashboard
        final redirectTo =
            user.role == 'shopowner' ? '/client-dashboard' : '/home';
        // ignore: avoid_print
        print(
            '[GoRouter][_redirectLogic] INVALID ROUTE "$location" for logged-in user -> redirecting to $redirectTo');
        return redirectTo;
      } else {
        // User not logged in and route is invalid - go to root (auth gate)
        // ignore: avoid_print
        print(
            '[GoRouter][_redirectLogic] INVALID ROUTE "$location" for anonymous user -> redirecting to /');
        return '/';
      }
    }

    // PHASE 3: Route is valid - check auth-based redirects
    if (location == '/') {
      if (user != null) {
        // User is logged in and on root - redirect to dashboard
        final redirectTo =
            user.role == 'shopowner' ? '/client-dashboard' : '/home';
        // ignore: avoid_print
        print(
            '[GoRouter][_redirectLogic] ROOT "/" with logged-in user -> redirecting to $redirectTo');
        return redirectTo;
      }
      // Not logged in and on root - stay on auth gate
      // ignore: avoid_print
      print(
          '[GoRouter][_redirectLogic] ROOT "/" without login -> staying on auth gate');
      return null;
    }

    // PHASE 4: Protected routes - ensure user is logged in
    const protectedRoutes = [
      '/home',
      '/explore',
      '/compare',
      '/saved',
      '/profile',
      '/offer-details',
      '/notifications',
      '/settings',
      '/client-dashboard',
      '/client-add',
      '/client-manage',
      '/client-enquiries',
      '/client-profile',
      '/new-offer',
      '/manage-offers',
    ];

    if (protectedRoutes.any((route) => location.startsWith(route))) {
      if (user == null) {
        // Trying to access protected route without login - go to auth
        // ignore: avoid_print
        print(
            '[GoRouter][_redirectLogic] PROTECTED ROUTE "$location" without login -> redirecting to /');
        return '/';
      }
      // User is logged in - allow access
      // ignore: avoid_print
      print(
          '[GoRouter][_redirectLogic] PROTECTED ROUTE "$location" with valid user -> allowing');
      return null;
    }

    // No redirect needed
    // ignore: avoid_print
    print('[GoRouter][_redirectLogic] ALLOWED -> no redirect');
    return null;
  }

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
  ];

  /// Check if a route path is valid
  static bool isValidRoute(String path) {
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
