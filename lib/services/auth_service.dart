import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/exceptions.dart';
import '../models/user.dart';
import '../models/client_panel_stage.dart';
import '../core/error_messages.dart';

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

  // Cache for stage determination to avoid redundant Firestore queries
  String? _cachedStageUid;

  // Track if initial auth check is complete
  bool _initialCheckComplete = false;
  bool get initialCheckComplete => _initialCheckComplete;

  bool get isBusy => _isBusy;
  String? get errorMessage => _errorMessage;
  ClientPanelStage get stage => _stage;

  AppUser? get currentUser => _currentUser;
  bool get isLoggedIn => _loggedIn;

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn();

  // Expose firestore for role checking in login screens
  FirebaseFirestore get firestore => _firestore;

  AuthService() {
    // Listen to Firebase Auth state changes (this fires immediately with current state)
    _auth.authStateChanges().listen(_handleAuthStateChanged);
    // Also check for persistent login immediately on startup
    // This ensures we have auth state before first route decision
    _initializeAuthState();
  }

  Future<void> _initializeAuthState() async {
    try {
      // Wait for Firebase to determine current auth state
      // This is important on app startup/reload
      await Future.delayed(const Duration(milliseconds: 100));

      // Check if Firebase already has currentUser
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        // User is already authenticated by Firebase
        await _loadUserFromFirestore(currentUser.uid);
        _loggedIn = true;
        await _determineStage(currentUser.uid);
        notifyListeners();
      } else {
        // Firebase says not logged in, but check SharedPreferences just in case
        final prefs = await SharedPreferences.getInstance();
        final wasLoggedIn = prefs.getBool('isLoggedIn') ?? false;
        if (wasLoggedIn) {
          // Stored flag says logged in, but Firebase says not - clear the flag
          await prefs.setBool('isLoggedIn', false);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during auth initialization: $e');
      }
    } finally {
      _initialCheckComplete = true;
      notifyListeners();
    }
  }

  Future<void> _checkPersistentLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      if (isLoggedIn && _auth.currentUser != null) {
        // User is already authenticated, load profile
        await _loadUserFromFirestore(_auth.currentUser!.uid);
        _loggedIn = true;
        await _determineStage(_auth.currentUser!.uid);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during persistent login check: $e');
      }
    } finally {
      _initialCheckComplete = true;
      notifyListeners();
    }
  }

  Future<void> _savePersistentLogin(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', isLoggedIn);
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
        // Load user profile and determine stage in parallel
        await Future.wait([
          _loadUserFromFirestore(user.uid),
          _determineStage(user.uid),
        ]);

        _loggedIn = true;
        await _savePersistentLogin(true);
        notifyListeners();
      } else {
        throw AuthException('No user found after sign-in.');
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        debugPrint(
            'FirebaseAuthException.signIn -> code=${e.code}, message=${e.message}');
      }
      _errorMessage = _getFirebaseErrorMessage(e.code);
      notifyListeners();
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Non-Firebase error during signIn: $e');
      }
      _errorMessage = 'Unable to sign in. Please try again.';
      notifyListeners();
      rethrow;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  // Determine approval stage for the user (with caching to avoid redundant queries)
  Future<void> _determineStage(String uid) async {
    // Skip if already cached for this uid
    if (_cachedStageUid == uid) {
      return;
    }

    final firestore = FirebaseFirestore.instance;

    // Check in parallel for better performance
    final futures = [
      firestore
          .collection('clients')
          .doc('approved')
          .collection('clients')
          .doc(uid)
          .get(),
      firestore
          .collection('clients')
          .doc('pending')
          .collection('clients')
          .doc(uid)
          .get(),
      firestore
          .collection('clients')
          .doc('rejected')
          .collection('clients')
          .doc(uid)
          .get(),
    ];

    final results = await Future.wait(futures);

    if (results[0].exists) {
      _stage = ClientPanelStage.active;
    } else if (results[1].exists) {
      _stage = ClientPanelStage.pendingApproval;
    } else if (results[2].exists) {
      _stage = ClientPanelStage.rejected;
    } else {
      _stage = ClientPanelStage.pendingApproval;
    }

    // Update cache
    _cachedStageUid = uid;
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
    required String city,
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
          'name': contactPerson, // Use contact person as name
          'email': email,
          'phone': phoneNumber,
          'role': 'shopowner', // IMPORTANT: Set role to shopowner

          // User Profile Fields (required for AppUser but not always provided during client signup)
          'address': address,
          'gender': '', // Will be filled during profile completion
          'dob': '', // Will be filled during profile completion

          // Business Information
          'businessName': businessName,
          'category': category,
          'location': location,
          'businessCategory': category,
          'city': city,

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
          'photoUrl': null,

          // Timestamps
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),

          // Additional fields for future use
          'isActive': true,
          'offersCount': 0,
          'isVerified': false,
        };

        // Save to both locations for consistency:
        // 1. Save to users/{uid} for primary user lookup
        // 2. Save to clients/pending/clients/{uid} for approval workflow
        await Future.wait([
          _firestore.collection('users').doc(user.uid).set(clientData),
          _firestore
              .collection('clients')
              .doc('pending')
              .collection('clients')
              .doc(user.uid)
              .set(clientData),
        ]);

        await _loadUserFromFirestore(user.uid);
        _loggedIn = true;
        await _determineStage(user.uid);
        await _savePersistentLogin(true);
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
    required String role, // 'user' or 'shopowner'
    String? address,
    String? gender,
    String? dob,
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
        await user.updateDisplayName(name);

        if (role == 'user') {
          // Only store essential user fields
          await _firestore.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'name': name,
            'email': email,
            'phone': phone,
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
            address: address ?? '',
            gender: gender ?? '',
            dob: dob ?? '',
            role: role,
            approvalStatus: 'pending',
            rejectionReason: null,
            businessName: '',
            contactPerson: '',
            phoneNumber: phone,
            location: '',
            category: '',
            gstNumber: null,
            shopLicenseNumber: null,
            businessRegistrationNumber: null,
          );
          await _firestore
              .collection('users')
              .doc(user.uid)
              .set(appUser.toMap());
        }

        // Load user profile and determine stage in parallel
        await Future.wait([
          _loadUserFromFirestore(user.uid),
          _determineStage(user.uid),
        ]);

        _loggedIn = true;
        await _savePersistentLogin(true);
        notifyListeners();
      } else {
        throw AuthException('Sign up failed: User creation failed.');
      }
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getFirebaseErrorMessage(e.code);
      notifyListeners();
      rethrow;
    } catch (e) {
      _errorMessage = 'Sign up failed. Please try again.';
      notifyListeners();
      rethrow;
    } finally {
      _isBusy = false;
      notifyListeners();
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
          // Create new profile with Google data - only essential fields
          if (role == 'user') {
            await _firestore.collection('users').doc(user.uid).set({
              'uid': user.uid,
              'name': user.displayName ?? '',
              'email': user.email ?? '',
              'phone': user.phoneNumber ?? '',
              'role': role,
              'createdAt': FieldValue.serverTimestamp(),
            });
            _currentUser = AppUser(
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
              location: '',
              category: '',
              gstNumber: null,
              shopLicenseNumber: null,
              businessRegistrationNumber: null,
            );
          }
        }

        _loggedIn = true;
        await _savePersistentLogin(true);
        notifyListeners();
      } else {
        throw AuthException(
          'Google sign-in failed: No user data from Firebase.',
        );
      }
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getFirebaseErrorMessage(e.code));
    } on Exception catch (e) {
      throw AuthException(ErrorMessages.friendlyErrorMessage(e));
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
      await _savePersistentLogin(false);
      notifyListeners();
    } catch (e) {
      throw AuthException('Sign out failed');
    }
  }

  /// Update profile. All fields are optional — only provided values will be updated.
  /// Supports uploading a profile image (File) — the url is stored under `photoUrl`.
  /// Returns `true` when an email verification for a new address was sent
  /// (the auth user will still have the old email until verification completes),
  /// otherwise returns `false` when no email change was requested.
  Future<bool> updateProfile({
    String? name,
    String? email,
    XFile? profileImage,
    String? phone,
    String? address,
    String? gender,
    String? dob,
  }) async {
    final user = _auth.currentUser;
    if (user == null || _currentUser == null) {
      throw AuthException('Not logged in');
    }

    // Update Firebase Auth properties selectively
    if (name != null && name != user.displayName) {
      await user.updateDisplayName(name);
    }

    var verificationSent = false;
    if (email != null && email != user.email) {
      // Use the newer API which sends a verification link to the new address
      // and only updates the auth email after the user clicks the link.
      // Store the pending email in Firestore so the app can show an appropriate
      // status to the user until they verify.
      await user.verifyBeforeUpdateEmail(email);
      verificationSent = true;
      // Do not overwrite the stored/active auth email yet — instead save as pending
    }

    // Upload profile image if provided
    String? uploadedPhotoUrl;
    if (profileImage != null) {
      try {
        final storageRef = FirebaseStorage.instance.ref().child(
            'users/${user.uid}/profile_${DateTime.now().millisecondsSinceEpoch}.jpg');
        final imageBytes = await profileImage.readAsBytes();

        // Use putData which works on all platforms
        final uploadTask = await storageRef.putData(
          imageBytes,
          SettableMetadata(contentType: 'image/jpeg'),
        );
        uploadedPhotoUrl = await uploadTask.ref.getDownloadURL();
      } catch (e) {
        debugPrint('Error uploading profile image: $e');
        throw AuthException(ErrorMessages.friendlyErrorMessage(e));
      }
    }

    // Prepare firestore update map — only include provided fields
    final updateData = <String, dynamic>{};
    if (name != null) updateData['name'] = name;
    if (email != null) {
      // Store as a pending email if a verification link was sent. The
      // auth user's active email will remain unchanged until verification.
      if (verificationSent) {
        updateData['pendingEmail'] = email;
      } else {
        updateData['email'] = email;
      }
    }
    if (phone != null) updateData['phone'] = phone;
    if (address != null) updateData['address'] = address;
    if (gender != null) updateData['gender'] = gender;
    if (dob != null) updateData['dob'] = dob;
    if (uploadedPhotoUrl != null) updateData['photoUrl'] = uploadedPhotoUrl;

    if (updateData.isNotEmpty) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(updateData, SetOptions(merge: true));
    }

    // Build new AppUser by merging existing values with updated fields
    _currentUser = AppUser(
      uid: user.uid,
      name: name ?? _currentUser!.name,
      // Keep current active email until the user verifies a pending change.
      email: verificationSent
          ? _currentUser!.email
          : (email ?? _currentUser!.email),
      phone: phone ?? _currentUser!.phone,
      address: address ?? _currentUser!.address,
      gender: gender ?? _currentUser!.gender,
      dob: dob ?? _currentUser!.dob,
      role: _currentUser!.role,
      approvalStatus: _currentUser!.approvalStatus,
      rejectionReason: _currentUser!.rejectionReason,
      businessName: _currentUser!.businessName,
      contactPerson: _currentUser!.contactPerson,
      phoneNumber: _currentUser!.phoneNumber,
      location: _currentUser!.location,
      category: _currentUser!.category,
      gstNumber: _currentUser!.gstNumber,
      shopLicenseNumber: _currentUser!.shopLicenseNumber,
      businessRegistrationNumber: _currentUser!.businessRegistrationNumber,
      photoUrl: uploadedPhotoUrl ?? _currentUser!.photoUrl,
    );

    notifyListeners();

    return verificationSent;
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
