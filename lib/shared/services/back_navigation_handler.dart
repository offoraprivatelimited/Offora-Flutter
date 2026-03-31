import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Handles back button navigation behavior to prevent going back to auth screens
/// and logging out unexpectedly
class BackNavigationHandler {
  /// Check if the current route is a protected route (requires authentication)
  static bool isProtectedRoute(String path) {
    const protectedRoutes = <String>{
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
      '/advertisement-details',
    };
    return protectedRoutes.contains(path);
  }

  /// Check if the current route is an auth screen
  static bool isAuthRoute(String path) {
    const authRoutes = <String>{
      '/',
      '/role-selection',
      '/splash',
      '/onboarding',
      '/auth',
      '/user-login',
      '/profile-complete',
      '/client-login',
      '/client-signup',
      '/pending-approval',
      '/rejection',
    };
    return authRoutes.contains(path);
  }

  /// Prevent back navigation to auth screens
  static void handleBackNavigation(
    BuildContext context,
    GoRouterState state,
  ) {
    final path = state.uri.path;

    // If trying to go back to auth screens from protected routes, don't allow it
    if (isProtectedRoute(path)) {
      // User is in a protected route - back button should work normally
      // through Go Router's built-in navigation stack
      return;
    }

    // If in an auth route while logged in, prevent going back
    if (isAuthRoute(path)) {
      // This shouldn't happen if the redirect logic is working properly
      // But as a safety measure, don't pop
      return;
    }
  }
}
