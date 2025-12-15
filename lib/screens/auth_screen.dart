import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'main_screen.dart';
import 'profile_complete_screen.dart';
import '../core/error_messages.dart';
import '../widgets/responsive_page.dart';

class AuthScreen extends StatefulWidget {
  static const String routeName = '/auth';
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLoading = false;
  late String _role;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && args['role'] is String) {
      _role = args['role'] as String;
    } else {
      _role = 'user';
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authService = context.read<AuthService>();
      // Pass the selected role to the sign-in logic (update AuthService as needed)
      await authService.signInWithGoogle(role: _role);

      if (!mounted) return;

      final user = authService.currentUser;
      if (user == null) {
        throw Exception('Sign in succeeded but user is null');
      }

      // Check if user needs to complete profile
      if (user.role == 'shopowner') {
        // Redirect to shopowner login (which will handle approval logic)
        Navigator.pushReplacementNamed(context, '/login');
      } else if (user.address.isEmpty ||
          user.gender.isEmpty ||
          user.dob.isEmpty) {
        Navigator.pushReplacementNamed(
          context,
          ProfileCompleteScreen.routeName,
        );
      } else {
        Navigator.pushReplacementNamed(context, MainScreen.routeName);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ErrorMessages.friendlyErrorMessage(e)),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/role-selection');
          },
        ),
        title: const Text('Sign in'),
        centerTitle: true,
        elevation: 0,
      ),
      body: ResponsivePage(
        child: Center(
          child: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 24.0),
                    child: CircularProgressIndicator(),
                  )
                else ...[
                  const Text(
                    'Welcome! Sign in to continue.',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF3C4043),
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFFDADCE0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 16,
                      ),
                    ),
                    onPressed: _isLoading ? null : _handleGoogleSignIn,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: Icon(
                            Icons.public,
                            color: Color(0xFF4285F4),
                            size: 20,
                          ),
                        ),
                        Text(
                          'Continue with Google',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
