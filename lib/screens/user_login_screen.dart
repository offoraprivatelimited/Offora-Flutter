import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'main_screen.dart';

class UserLoginScreen extends StatefulWidget {
  static const String routeName = '/user-login';
  const UserLoginScreen({super.key});

  @override
  State<UserLoginScreen> createState() => _UserLoginScreenState();
}

class _UserLoginScreenState extends State<UserLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLogin = true;

  // Signup fields
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  final _cityController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _toggleForm() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  Future<void> _handleGoogleSignIn() async {
    final authService = context.read<AuthService>();
    try {
      await authService.signInWithGoogle(role: 'user');
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, MainScreen.routeName);
    } catch (e) {
      _showError('Google sign-in failed: ${e.toString()}');
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    final authService = context.read<AuthService>();
    try {
      await authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // Role check: Only allow if UID is in users, not clients
      final uid = authService.currentUser?.uid;
      final firestore = authService.firestore;
      if (uid != null) {
        final userDoc = await firestore.collection('users').doc(uid).get();
        final clientDoc = await firestore.collection('clients').doc(uid).get();
        if (userDoc.exists) {
          // Allowed: user login
          if (!mounted) return;
          Navigator.pushReplacementNamed(context, MainScreen.routeName);
        } else if (clientDoc.exists) {
          // Block: shop owner trying to log in as user
          await authService.signOut();
          _showError(
              'This account is registered as a shop owner. Please use the shop owner login.');
        } else {
          // Not found in either collection
          await authService.signOut();
          _showError(
              'No user record found. Please sign up or contact support.');
        }
      }
    } catch (e) {
      _showError('Login failed: ${e.toString()}');
    }
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;
    final authService = context.read<AuthService>();
    try {
      await authService.signUpWithEmail(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        phone: _phoneController.text.trim(),
        role: 'user',
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, MainScreen.routeName);
    } catch (e) {
      _showError('Signup failed: ${e.toString()}');
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

    return Scaffold(
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
                    onPressed: () => Navigator.pushReplacementNamed(
                        context, '/role-selection'),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color.fromARGB(255, 0, 0, 0), // darkBlue
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
                                  // Back button moved to top-level SafeArea
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
                                        validator: (v) => v == null || v.isEmpty
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
                                        labelText: 'Password',
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
                                                ? Icons.visibility_off_outlined
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
                                        focusedErrorBorder: OutlineInputBorder(
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
                                    const SizedBox(height: 24),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 54,
                                      child: ElevatedButton(
                                        onPressed: _isLogin
                                            ? _handleLogin
                                            : _handleSignup,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: darkBlue,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          elevation: 8,
                                          shadowColor: darkBlue.withAlpha(55),
                                        ),
                                        child: Text(
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
                                            tapTargetSize: MaterialTapTargetSize
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
                                        onPressed: _handleGoogleSignIn,
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
    );
  }
}
