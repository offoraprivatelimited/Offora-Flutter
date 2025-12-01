import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../core/exceptions.dart';
import '../models/user.dart';
import '../models/client_panel_stage.dart';

class AuthService extends ChangeNotifier {
  /// Refreshes the current user's profile from Firestore and updates approval stage.
  Future<void> refreshProfile() async {
    if (_currentUser == null) return;
    await _loadUserFromFirestore(_currentUser!.uid);
    await _determineStage(_currentUser!.uid);
    notifyListeners();
  }

  AppUser? _currentUser;
  bool _loggedIn = false;
  // Track busy state and error message
  bool _isBusy = false;
  String? _errorMessage;

  // Track approval stage
  ClientPanelStage _stage = ClientPanelStage.pendingApproval;

  bool get isBusy => _isBusy;
  String? get errorMessage => _errorMessage;
  ClientPanelStage get stage => _stage;

  AppUser? get currentUser => _currentUser;
  bool get isLoggedIn => _loggedIn;

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn();

  AuthService() {
    // Listen to Firebase Auth state changes
    _auth.authStateChanges().listen(_handleAuthStateChanged);
  }

  Future<void> _handleAuthStateChanged(User? user) async {
    if (user != null) {
      // User is signed in, load their profile
      try {
        await _loadUserFromFirestore(user.uid);
        // Keep `_currentUser` as loaded (may be null if no profile present)
        _loggedIn = true;
      } catch (e) {
        if (kDebugMode) {
          print('Error loading user profile: $e');
        }
        // Keep the auth state but clear currentUser so UI can react accordingly
        _loggedIn = true;
        _currentUser = null;
      }
    } else {
      // User is signed out
      _loggedIn = false;
      _currentUser = null;
    }
    notifyListeners();
  }

  // --- Email/Password Sign In ---
  Future<void> signIn({required String email, required String password}) async {
    _isBusy = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user != null) {
        await _loadUserFromFirestore(user.uid);
        _loggedIn = true;
        await _determineStage(user.uid);
        notifyListeners();
      } else {
        throw AuthException('No user found after sign-in.');
      }
    } on FirebaseAuthException catch (e) {
      // Log FirebaseAuthException details for debugging (visible in console / browser)
      if (kDebugMode) {
        debugPrint(
            'FirebaseAuthException.signIn -> code=${e.code}, message=${e.message}');
      } else {
        // Ensure we still have some logging in non-debug runs
      }
      _errorMessage = _getFirebaseErrorMessage(e.code);
      notifyListeners();
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Non-Firebase error during signIn: $e');
      } else {}
      _errorMessage = 'Unable to sign in. Please try again.';
      notifyListeners();
      rethrow;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  // Determine approval stage for the user
  Future<void> _determineStage(String uid) async {
    final firestore = FirebaseFirestore.instance;
    final approvedSnap = await firestore
        .collection('clients')
        .doc('approved')
        .collection('clients')
        .doc(uid)
        .get();
    if (approvedSnap.exists) {
      _stage = ClientPanelStage.active;
      return;
    }
    final pendingSnap = await firestore
        .collection('clients')
        .doc('pending')
        .collection('clients')
        .doc(uid)
        .get();
    if (pendingSnap.exists) {
      _stage = ClientPanelStage.pendingApproval;
      return;
    }
    final rejectedSnap = await firestore
        .collection('clients')
        .doc('rejected')
        .collection('clients')
        .doc(uid)
        .get();
    if (rejectedSnap.exists) {
      _stage = ClientPanelStage.rejected;
      return;
    }
    _stage = ClientPanelStage.pendingApproval;
  }

  // Register client (shop owner) - stores all information in Firestore
  Future<void> registerClient({
    required String email,
    required String password,
    required String businessName,
    required String contactPerson,
    required String phoneNumber,
    required String address,
    required String location,
    required String category,
    String? gstNumber,
    String? shopLicenseNumber,
    String? businessRegistrationNumber,
  }) async {
    _isBusy = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user != null) {
        final clientData = {
          // Authentication & Identity
          'uid': user.uid,
          'email': email,

          // Business Information
          'businessName': businessName,
          'businessCategory': category,
          'location': location,
          'address': address,

          // Contact Information
          'contactPerson': contactPerson,
          'phoneNumber': phoneNumber,

          // Business Registration Details (Optional)
          'gstNumber': gstNumber,
          'shopLicenseNumber': shopLicenseNumber,
          'businessRegistrationNumber': businessRegistrationNumber,

          // Approval Status & Metadata
          'approvalStatus': 'pending',
          'rejectionReason': null,
          'lastSignInAt': null,

          // Timestamps
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),

          // Additional fields for future use
          'isActive': true,
          'offersCount': 0,
          'isVerified': false,
        };

        // Save to clients/pending/clients/{uid} (hierarchical structure)
        await FirebaseFirestore.instance
            .collection('clients')
            .doc('pending')
            .collection('clients')
            .doc(user.uid)
            .set(clientData);

        await _loadUserFromFirestore(user.uid);
        _loggedIn = true;
        await _determineStage(user.uid);
        notifyListeners();
      } else {
        throw AuthException('No user found after sign-up.');
      }
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getFirebaseErrorMessage(e.code);
      notifyListeners();
      rethrow;
    } catch (e) {
      _errorMessage = 'Unable to create account.';
      notifyListeners();
      rethrow;
    } finally {
      _isBusy = false;
      notifyListeners();
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
    required String role, // 'user' or 'shopowner'
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;

      if (user != null) {
        await user.updateDisplayName(name);

        if (role == 'user') {
          // Only store user fields
          await _firestore.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'name': name,
            'email': email,
            'phone': phone,
            'address': address,
            'gender': gender,
            'dob': dob,
            'role': role,
            'createdAt': FieldValue.serverTimestamp(),
          });
        } else {
          // Store shop owner fields
          final appUser = AppUser(
            uid: user.uid,
            name: name,
            email: email,
            phone: phone,
            address: address,
            gender: gender,
            dob: dob,
            role: role,
            approvalStatus: 'pending',
            rejectionReason: null,
            businessName: '',
            contactPerson: '',
            phoneNumber: phone,
          );
          await _firestore
              .collection('users')
              .doc(user.uid)
              .set(appUser.toMap());
        }

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
  Future<void> signInWithGoogle({String role = 'user'}) async {
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
            role: role,
            approvalStatus: 'pending',
            rejectionReason: null,
            businessName: '',
            contactPerson: '',
            phoneNumber: user.phoneNumber ?? '',
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
    // Try `users/{uid}` first
    final userDoc = await _firestore.collection('users').doc(uid).get();
    if (userDoc.exists && userDoc.data() != null) {
      _currentUser = AppUser.fromMap(userDoc.data() as Map<String, dynamic>);
      return;
    }

    // Then try clients/{uid}
    final clientDirect = await _firestore.collection('clients').doc(uid).get();
    if (clientDirect.exists && clientDirect.data() != null) {
      _currentUser =
          AppUser.fromMap(clientDirect.data() as Map<String, dynamic>);
      return;
    }

    // Then try hierarchical client locations: pending / approved / rejected
    final statuses = ['approved', 'pending', 'rejected'];
    for (final status in statuses) {
      final doc = await _firestore
          .collection('clients')
          .doc(status)
          .collection('clients')
          .doc(uid)
          .get();
      if (doc.exists && doc.data() != null) {
        _currentUser = AppUser.fromMap(doc.data() as Map<String, dynamic>);
        return;
      }
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
      role: _currentUser!.role,
      approvalStatus: _currentUser!.approvalStatus,
      rejectionReason: _currentUser!.rejectionReason,
      businessName: _currentUser!.businessName,
      contactPerson: _currentUser!.contactPerson,
      phoneNumber: phone,
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
