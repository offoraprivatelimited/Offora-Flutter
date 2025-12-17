import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../models/client_panel_stage.dart';
import '../../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const String routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  // Track if we've already redirected to prevent multiple redirects
  bool _hasRedirected = false;

  void _goToRoleSelection() {
    debugPrint(
        '[LoginScreen] Back button pressed - attempting to navigate to role selection');

    try {
      context.goNamed('role-selection');
      debugPrint('[LoginScreen] ✓ Successfully navigated to role selection');
    } catch (e) {
      debugPrint('[LoginScreen] ✗ Error navigating to role selection: $e');
      // Fallback: try popping
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
        debugPrint('[LoginScreen] Fallback: Used pop()');
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = context.watch<AuthService>();

    // Only route if: user is logged in AND we haven't already redirected
    if (!auth.isLoggedIn || _hasRedirected) {
      return;
    }

    // Mark as redirected to prevent multiple navigations
    _hasRedirected = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (auth.stage == ClientPanelStage.active) {
        context.goNamed('client-dashboard');
      } else if (auth.stage == ClientPanelStage.pendingApproval) {
        context.goNamed('pending-approval');
      } else if (auth.stage == ClientPanelStage.rejected) {
        context.goNamed('rejection');
      }
    });
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Reset redirect flag when attempting new login
    _hasRedirected = false;

    final auth = context.read<AuthService>();
    try {
      await auth.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Role check: Only allow if UID is in clients collections (hierarchical structure)
      final uid = auth.currentUser?.uid;
      final firestore = auth.firestore;
      if (uid != null) {
        // Check hierarchical client locations: approved, pending, rejected
        final statuses = ['approved', 'pending', 'rejected'];
        bool isClient = false;
        for (final status in statuses) {
          final doc = await firestore
              .collection('clients')
              .doc(status)
              .collection('clients')
              .doc(uid)
              .get();
          if (doc.exists) {
            isClient = true;
            break;
          }
        }

        if (isClient) {
          // Allowed: shop owner login
          // didChangeDependencies will handle routing once state updates
          debugPrint('[LoginScreen] Login successful for shop owner: $uid');
        } else {
          // Check if it's a regular user trying to log in as shop owner
          final userDoc = await firestore.collection('users').doc(uid).get();
          if (userDoc.exists) {
            // Block: user trying to log in as shop owner
            await auth.signOut();
            _showError(
                'This account is registered as a user. Please use the user login.');
          } else {
            // Not found in any collection
            await auth.signOut();
            _showError(
                'No shop owner record found. Please sign up or contact support.');
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      _showError(auth.errorMessage ?? 'Unable to sign in. Please try again.');
      debugPrint('[LoginScreen] Firebase auth error: ${e.code}');
    } catch (e) {
      _showError(auth.errorMessage ?? 'Unable to sign in. Please try again.');
      debugPrint('[LoginScreen] Login error: $e');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final theme = Theme.of(context);
    // Use premium colors to match signup screen
    const darkBlue = Color(0xFF1F477D);
    const brightGold = Color(0xFFF0B84D);
    const darkerGold = Color(0xFFA3834D);

    return PopScope(
      canPop: false,
      onPopInvoked: (_) {
        debugPrint('[LoginScreen] System back pressed (PopScope.onPopInvoked)');
        _goToRoleSelection();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        body: SafeArea(
          child: LayoutBuilder(builder: (context, constraints) {
            final isWide = constraints.maxWidth > 760;
            return Stack(
              children: [
                // Decorative background shapes
                Positioned(
                  top: -constraints.maxWidth * 0.25,
                  left: -constraints.maxWidth * 0.2,
                  child: Container(
                    width: constraints.maxWidth * 0.7,
                    height: constraints.maxWidth * 0.7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          darkBlue.withAlpha(242),
                          darkBlue.withAlpha(153)
                        ],
                        center: Alignment.topLeft,
                        radius: 0.8,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: -constraints.maxWidth * 0.15,
                  right: -constraints.maxWidth * 0.25,
                  child: Container(
                    width: constraints.maxWidth * 0.5,
                    height: constraints.maxWidth * 0.5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          brightGold.withAlpha(255),
                          brightGold.withAlpha(217)
                        ],
                        center: Alignment.topRight,
                        radius: 0.9,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: darkerGold.withAlpha(56),
                          blurRadius: 40,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
                // Lower arc / shadow
                Positioned(
                  bottom: -constraints.maxWidth * 0.25,
                  left: -constraints.maxWidth * 0.2,
                  child: Container(
                    width: constraints.maxWidth * 0.8,
                    height: constraints.maxWidth * 0.5,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(constraints.maxWidth),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [darkerGold.withAlpha(46), Colors.transparent],
                      ),
                    ),
                  ),
                ),

                // Center card / form
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: isWide ? 480 : 340),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: isWide ? 16 : 8, vertical: 18),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(242),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(31),
                              blurRadius: 24,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Welcome back',
                                          style: theme.textTheme.headlineSmall
                                              ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            color: darkBlue,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'Sign in to access your Offora client tools',
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Mini logo accent
                                  Container(
                                    width: 90,
                                    height: 90,
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color.fromRGBO(
                                                  163, 131, 77, 1)
                                              .withAlpha(64),
                                          blurRadius: 12,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: Image.asset(
                                      'assets/images/logo/original/Logo_without_text_without_background.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 22),

                              // Form
                              Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    TextFormField(
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      cursorColor: const Color(0xFF1F477D),
                                      decoration: InputDecoration(
                                        labelText: 'Work email',
                                        labelStyle: const TextStyle(
                                          color: Color(0xFF666666),
                                          fontWeight: FontWeight.w500,
                                        ),
                                        hintText: 'you@business.com',
                                        hintStyle: const TextStyle(
                                          color: Color(0xFFBBBBBB),
                                        ),
                                        prefixIcon: const Icon(
                                            Icons.email_outlined,
                                            color: Color(0xFF1F477D)),
                                        filled: true,
                                        fillColor: Colors.white,
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFE0E0E0),
                                            width: 1.5,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                            color: Color(0xFF1F477D),
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                      validator: _validateEmail,
                                      textInputAction: TextInputAction.next,
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: _passwordController,
                                      obscureText: _obscurePassword,
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      cursorColor: const Color(0xFF1F477D),
                                      decoration: InputDecoration(
                                        labelText: 'Password',
                                        labelStyle: const TextStyle(
                                          color: Color(0xFF666666),
                                          fontWeight: FontWeight.w500,
                                        ),
                                        prefixIcon: const Icon(
                                            Icons.lock_outline,
                                            color: Color(0xFF1F477D)),
                                        suffixIcon: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _obscurePassword =
                                                  !_obscurePassword;
                                            });
                                          },
                                          icon: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_off_outlined
                                                : Icons.visibility_outlined,
                                            color: const Color(0xFF1F477D),
                                          ),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFE0E0E0),
                                            width: 1.5,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                            color: Color(0xFF1F477D),
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'Password is required';
                                        }
                                        if (value.trim().length < 6) {
                                          return 'Password must be at least 6 characters';
                                        }
                                        return null;
                                      },
                                      onFieldSubmitted: (_) => _handleLogin(),
                                    ),
                                    const SizedBox(height: 12),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: () {
                                          context.goNamed('client-signup');
                                        },
                                        style: TextButton.styleFrom(
                                          foregroundColor: darkBlue,
                                        ),
                                        child: const Text(
                                            'New to Offora? Create an account'),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 54,
                                      child: ElevatedButton(
                                        onPressed:
                                            auth.isBusy ? null : _handleLogin,
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12)),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 14),
                                          backgroundColor: darkBlue,
                                          elevation: 6,
                                          shadowColor: darkerGold.withAlpha(46),
                                        ),
                                        child: auth.isBusy
                                            ? const SizedBox(
                                                height: 20,
                                                width: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    'Sign in',
                                                    style: theme
                                                        .textTheme.labelLarge
                                                        ?.copyWith(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      letterSpacing: 0.6,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Custom floating back button (top left) - moved to top of stack
                Positioned(
                  top: 8,
                  left: 8,
                  child: Material(
                    color: Colors.transparent,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: Color(0xFF1F477D)),
                      tooltip: 'Back to role selection',
                      onPressed: () {
                        debugPrint('[LoginScreen] Custom back button TAPPED');
                        _goToRoleSelection();
                      },
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^([\w\.-]+)@([\w-]+)\.([\w-]{2,})$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }
}
