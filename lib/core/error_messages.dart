import 'package:firebase_auth/firebase_auth.dart';

class ErrorMessages {
  static String firebaseAuthMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Wrong password or invalid credentials.';
      case 'email-already-in-use':
        return 'Email already exists.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with a different sign-in method.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'user-disabled':
        return 'This account has been disabled.';
      default:
        return 'An unexpected authentication error occurred.';
    }
  }

  /// Returns a user-friendly message for many common exception types.
  static String friendlyErrorMessage(Object error) {
    try {
      if (error is FirebaseAuthException) {
        return firebaseAuthMessage(error.code);
      }

      if (error is FirebaseException) {
        // Some FirebaseExceptions have a `message` which may be user-friendly.
        return error.message ?? 'A server error occurred. Please try again.';
      }

      // Fallback for other exception types
      if (error is Exception) {
        return 'Something went wrong. Please try again.';
      }

      return 'An unexpected error occurred. Please try again.';
    } catch (_) {
      return 'An unexpected error occurred. Please try again.';
    }
  }
}
