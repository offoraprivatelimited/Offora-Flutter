import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../shared/services/auth_service.dart';
import '../../../core/errors/error_messages.dart';

class UserLoginScreen extends StatefulWidget {
  static const String routeName = '/user-login';
  const UserLoginScreen({super.key});

  @override
  State<UserLoginScreen> createState() => _UserLoginScreenState();
}

class _UserLoginScreenState extends State<UserLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _phoneController;
  late TextEditingController _cityController;
  late TextEditingController _confirmPasswordController;

  bool _isLogin = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _phoneController = TextEditingController();
    _cityController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    // Check if user is already logged in after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkIfAlreadyLoggedIn();
    });
  }

  /// Check if user is already logged in and redirect to home
  void _checkIfAlreadyLoggedIn() {
    if (!mounted) return;

    final auth = context.read<AuthService>();

    // If initial check isn't complete yet, wait and check again
    if (!auth.initialCheckComplete) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _checkIfAlreadyLoggedIn();
      });
      return;
    }

    // User already logged in - redirect to home
    if (auth.isLoggedIn && auth.currentUser != null) {
      if (kDebugMode) {
        print('[UserLoginScreen] User already logged in, redirecting to home');
      }
      context.go('/home');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _toggleForm() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      _showError('Please fix the errors in the form');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final auth = context.read<AuthService>();
      await auth.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        _showSuccess('Login successful!');
        // Wait a moment for the message to show, then navigate
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          // Use go with offset parameter to replace current route
          // This prevents /user-login from being in browser history
          context.go('/home');
        }
      }
    } catch (e) {
      if (mounted) {
        _showError(ErrorMessages.friendlyErrorMessage(e));
        debugPrint('[UserLoginScreen] Login error: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) {
      _showError('Please fix the errors in the form');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final auth = context.read<AuthService>();
      await auth.signUpWithEmail(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        phone: _phoneController.text.trim(),
        role: 'user',
      );

      if (!mounted) return;

      // Wait for auth state to be fully established
      await Future.delayed(const Duration(milliseconds: 500));

      _showSuccess('Account created successfully!');
      // Wait a moment for the message to show, then navigate
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        // Use go to navigate to home
        // The redirect on user-login route will prevent going back to login
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        _showError(ErrorMessages.friendlyErrorMessage(e));
        debugPrint('[UserLoginScreen] Signup error: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    try {
      final auth = context.read<AuthService>();

      // Show message before redirect (for web, this will redirect to Google)
      _showSuccess('Opening Google Sign-In...');

      await auth.signInWithGoogle();

      // For web redirect flow, this code may not run as the page reloads
      // For mobile, it will run after successful sign-in
      if (mounted && auth.isLoggedIn) {
        _showSuccess('Google sign in successful!');
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          context.go('/home');
        }
      }
    } catch (e) {
      if (mounted) {
        _showError(ErrorMessages.friendlyErrorMessage(e));
        if (kDebugMode) {
          print('[UserLoginScreen] Google sign in error: $e');
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red.shade600,
    ));
  }

  void _showSuccess(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.green.shade600,
    ));
  }

  Widget _styledField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(
        color: Colors.black87,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      cursorColor: const Color(0xFF1F477D),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Color(0xFF666666),
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(icon, color: const Color(0xFF1F477D)),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFE0E0E0),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF1F477D),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 2,
          ),
        ),
      ),
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    const darkBlue = Color(0xFF1F477D);
    const darkerGold = Color(0xFFA3834D);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        // Prevent back navigation - navigate to role selection instead
        if (didPop) return;
        context.go('/role-selection');
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: SafeArea(
          child: LayoutBuilder(builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            return Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  child: SafeArea(
                    child: IconButton(
                      onPressed: () => context.go('/role-selection'),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                      tooltip: 'Back to role selection',
                    ),
                  ),
                ),
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: isWide ? 640 : 420),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: isWide ? 32 : 20, vertical: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: darkerGold.withAlpha(150),
                              blurRadius: 25,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 28, vertical: 32),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _isLogin
                                                ? 'Welcome back'
                                                : 'Create account',
                                            style: const TextStyle(
                                              fontSize: 26,
                                              fontWeight: FontWeight.w900,
                                              color: darkBlue,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            _isLogin
                                                ? 'Sign in to continue exploring offers.'
                                                : 'Sign up to save and follow offers.',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF666666),
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 64,
                                      height: 64,
                                      child: Image.asset(
                                        'assets/images/logo/original/Logo_without_text_without_background.png',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 28),
                                Form(
                                  key: _formKey,
                                  child: Column(
                                    children: [
                                      if (!_isLogin) ...[
                                        _styledField(
                                            controller: _nameController,
                                            label: 'Full name',
                                            icon: Icons.person_outline),
                                        const SizedBox(height: 14),
                                        _styledField(
                                            controller: _phoneController,
                                            label: 'Phone',
                                            icon: Icons.phone_outlined,
                                            keyboardType: TextInputType.phone),
                                        const SizedBox(height: 14),
                                        _styledField(
                                            controller: _cityController,
                                            label: 'City',
                                            icon: Icons.location_city_outlined),
                                        const SizedBox(height: 14),
                                      ],
                                      _styledField(
                                          controller: _emailController,
                                          label: 'Email address',
                                          icon: Icons.email_outlined,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          validator: (v) =>
                                              v == null || v.isEmpty
                                                  ? 'Please enter your email'
                                                  : null),
                                      const SizedBox(height: 14),
                                      TextFormField(
                                        controller: _passwordController,
                                        obscureText: _obscurePassword,
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        cursorColor: darkBlue,
                                        decoration: InputDecoration(
                                          labelText: _isLogin
                                              ? 'Password'
                                              : 'Create Password',
                                          labelStyle: const TextStyle(
                                            color: Color(0xFF666666),
                                            fontWeight: FontWeight.w500,
                                          ),
                                          prefixIcon: const Icon(
                                              Icons.lock_outline,
                                              color: darkBlue),
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _obscurePassword
                                                  ? Icons
                                                      .visibility_off_outlined
                                                  : Icons.visibility_outlined,
                                              color: darkBlue,
                                            ),
                                            onPressed: () => setState(() =>
                                                _obscurePassword =
                                                    !_obscurePassword),
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
                                              color: darkBlue,
                                              width: 2,
                                            ),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: const BorderSide(
                                              color: Colors.red,
                                              width: 1.5,
                                            ),
                                          ),
                                          focusedErrorBorder:
                                              OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: const BorderSide(
                                              color: Colors.red,
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                        validator: (v) => v == null ||
                                                v.length < 6
                                            ? 'Password must be at least 6 characters'
                                            : null,
                                      ),
                                      if (!_isLogin) ...[
                                        const SizedBox(height: 14),
                                        TextFormField(
                                          controller:
                                              _confirmPasswordController,
                                          obscureText: _obscureConfirmPassword,
                                          style: const TextStyle(
                                            color: Colors.black87,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          cursorColor: darkBlue,
                                          decoration: InputDecoration(
                                            labelText: 'Confirm Password',
                                            labelStyle: const TextStyle(
                                              color: Color(0xFF666666),
                                              fontWeight: FontWeight.w500,
                                            ),
                                            prefixIcon: const Icon(
                                                Icons.lock_outline,
                                                color: darkBlue),
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                _obscureConfirmPassword
                                                    ? Icons
                                                        .visibility_off_outlined
                                                    : Icons.visibility_outlined,
                                                color: darkBlue,
                                              ),
                                              onPressed: () => setState(() =>
                                                  _obscureConfirmPassword =
                                                      !_obscureConfirmPassword),
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
                                                color: darkBlue,
                                                width: 2,
                                              ),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: const BorderSide(
                                                color: Colors.red,
                                                width: 1.5,
                                              ),
                                            ),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: const BorderSide(
                                                color: Colors.red,
                                                width: 2,
                                              ),
                                            ),
                                          ),
                                          validator: (v) {
                                            if (v == null || v.isEmpty) {
                                              return 'Please confirm your password';
                                            }
                                            if (v != _passwordController.text) {
                                              return 'Passwords do not match';
                                            }
                                            return null;
                                          },
                                        ),
                                      ],
                                      const SizedBox(height: 24),
                                      SizedBox(
                                        width: double.infinity,
                                        height: 54,
                                        child: ElevatedButton(
                                          onPressed: _isLoading
                                              ? null
                                              : (_isLogin
                                                  ? _handleLogin
                                                  : _handleSignup),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: _isLoading
                                                ? Colors.grey
                                                : darkBlue,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            elevation: 8,
                                            shadowColor: darkBlue.withAlpha(55),
                                          ),
                                          child: _isLoading
                                              ? const SizedBox(
                                                  height: 24,
                                                  width: 24,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                            Color>(
                                                      Colors.white,
                                                    ),
                                                  ),
                                                )
                                              : Text(
                                                  _isLogin
                                                      ? 'Sign in'
                                                      : 'Create account',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 16,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            _isLogin
                                                ? 'Don\'t have an account? '
                                                : 'Already have an account? ',
                                            style: const TextStyle(
                                              color: Color(0xFF666666),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: _toggleForm,
                                            style: TextButton.styleFrom(
                                              padding: EdgeInsets.zero,
                                              tapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                            ),
                                            child: Text(
                                              _isLogin ? 'Sign up' : 'Sign in',
                                              style: const TextStyle(
                                                color: darkBlue,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                decoration:
                                                    TextDecoration.underline,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Divider(
                                              color: Colors.grey.shade300,
                                              thickness: 1,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12),
                                            child: Text(
                                              'or',
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Divider(
                                              color: Colors.grey.shade300,
                                              thickness: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      SizedBox(
                                        width: double.infinity,
                                        height: 52,
                                        child: OutlinedButton(
                                          onPressed: _isLoading
                                              ? null
                                              : _handleGoogleSignIn,
                                          style: OutlinedButton.styleFrom(
                                            side: const BorderSide(
                                              color: Color(0xFFDADADA),
                                              width: 1,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            backgroundColor: Colors.white,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: Image.network(
                                                  'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return const Icon(
                                                      Icons.login_outlined,
                                                      size: 20,
                                                      color: Color(0xFF4285F4),
                                                    );
                                                  },
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              const Text(
                                                'Continue with Google',
                                                style: TextStyle(
                                                  color: Color(0xFF3C3C3C),
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 15,
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
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
