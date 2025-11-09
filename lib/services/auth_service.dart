import '../core/exceptions.dart';
import '../models/user.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart'; // <--- Ensure this is the import

class AuthService extends ChangeNotifier {
  AppUser? _currentUser;
  bool _loggedIn = false;

  AppUser? get currentUser => _currentUser;
  bool get isLoggedIn => _loggedIn;

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  // FIX 1: Use the standard constructor GoogleSignIn()
  final _googleSignIn = GoogleSignIn();

  // --- Email/Password Sign In ---
  Future<void> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;

      if (user != null) {
        await _loadUserFromFirestore(user.uid);
        _loggedIn = true;
        notifyListeners();
      } else {
        throw AuthException('No user found after sign-in.');
      }
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getFirebaseErrorMessage(e.code));
    }
  }

  // --- Email/Password Sign Up ---
  Future<void> signUpWithEmail({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String address,
    required String gender,
    required String dob,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;

      if (user != null) {
        await user.updateDisplayName(name);

        final appUser = AppUser(
          uid: user.uid,
          name: name,
          email: email,
          phone: phone,
          address: address,
          gender: gender,
          dob: dob,
        );
        await _firestore.collection('users').doc(user.uid).set(appUser.toMap());

        _currentUser = appUser;
        _loggedIn = true;
        notifyListeners();
      } else {
        throw AuthException('Sign up failed: User creation failed.');
      }
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getFirebaseErrorMessage(e.code));
    }
  }

  // --- Google Sign In with Web Support ---
  Future<void> signInWithGoogle() async {
    try {
      UserCredential? userCred;

      if (kIsWeb) {
        // Web-specific sign in using Firebase Auth directly
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');

        try {
          userCred = await _auth.signInWithPopup(googleProvider);
        } catch (e) {
          // Fallback to redirect method if popup fails
          await _auth.signInWithRedirect(googleProvider);
          // Get redirect result (this should be called after returning from redirect)
          userCred = await _auth.getRedirectResult();
        }
      } else {
        // Mobile/Desktop flow using GoogleSignIn package
        final GoogleSignInAccount? account = await _googleSignIn.signIn();
        if (account == null) {
          throw AuthException('Google sign-in cancelled.');
        }

        final GoogleSignInAuthentication googleAuth =
            await account.authentication;
        final String? idToken = googleAuth.idToken;

        if (idToken == null) {
          throw AuthException(
              'Failed to retrieve ID Token. Check client setup.');
        }

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: idToken,
        );

        userCred = await _auth.signInWithCredential(credential);
      }

      final user = userCred.user;

      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          // Use existing Firestore profile data (Casting for type safety)
          _currentUser = AppUser.fromMap(doc.data() as Map<String, dynamic>);
        } else {
          // Create new profile with Google data
          final appUser = AppUser(
            uid: user.uid,
            name: user.displayName ?? '',
            email: user.email ?? '',
            phone: user.phoneNumber ?? '',
            address: '',
            gender: '',
            dob: '',
          );
          await _firestore
              .collection('users')
              .doc(user.uid)
              .set(appUser.toMap());
          _currentUser = appUser;
        }

        _loggedIn = true;
        notifyListeners();
      } else {
        throw AuthException(
          'Google sign-in failed: No user data from Firebase.',
        );
      }
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getFirebaseErrorMessage(e.code));
    } on Exception catch (e) {
      throw AuthException('Google Sign-In failed: ${e.toString()}');
    }
  }

  // --- Utility Methods ---

  Future<void> _loadUserFromFirestore(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      _currentUser = AppUser.fromMap(doc.data() as Map<String, dynamic>);
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      _currentUser = null;
      _loggedIn = false;
      notifyListeners();
    } catch (e) {
      throw AuthException('Sign out failed');
    }
  }

  Future<void> updateProfile({
    required String name,
    required String phone,
    required String address,
    required String gender,
    required String dob,
  }) async {
    final user = _auth.currentUser;
    if (user == null || _currentUser == null) {
      throw AuthException('Not logged in');
    }

    if (name != user.displayName) {
      await user.updateDisplayName(name);
    }

    final updatedUser = AppUser(
      uid: user.uid,
      name: name,
      email: _currentUser!.email,
      phone: phone,
      address: address,
      gender: gender,
      dob: dob,
    );

    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(updatedUser.toMap(), SetOptions(merge: true));

    _currentUser = updatedUser;
    notifyListeners();
  }

  String _getFirebaseErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Wrong password or invalid credentials.';
      case 'email-already-in-use':
        return 'The email address is already in use.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'operation-not-allowed':
        return 'Email/Password sign-in is not enabled.';
      case 'invalid-email':
        return 'The email address is not valid.';
      default:
        return 'An unexpected error occurred: $code';
    }
  }
}
