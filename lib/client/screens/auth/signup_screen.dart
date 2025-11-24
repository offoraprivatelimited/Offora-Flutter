import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/client_panel_stage.dart';
import '../../../services/auth_service.dart';
import '../dashboard/dashboard_screen.dart';
import 'pending_approval_page.dart';
import 'rejection_page.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  static const String routeName = '/signup';

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _addressController = TextEditingController();
  final _locationController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _selectedCategory;
  final List<String> _categories = [
    'Grocery',
    'Supermarket',
    'Restaurant',
    'Cafe',
    'Bakery',
    'Pharmacy',
    'Electronics',
    'Mobile & Accessories',
    'Fashion & Apparel',
    'Footwear',
    'Jewelry',
    'Home Decor',
    'Furniture',
    'Hardware',
    'Automotive',
    'Books & Stationery',
    'Toys & Games',
    'Sports & Fitness',
    'Beauty & Cosmetics',
    'Salon & Spa',
    'Pet Supplies',
    'Dairy & Produce',
    'Electronics Repair',
    'Optical',
    'Travel & Tours',
    'Department Store',
    'Other',
  ];

  @override
  void dispose() {
    _businessNameController.dispose();
    _contactNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _addressController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = context.watch<AuthService>();
    if (!auth.isLoggedIn) {
      return;
    }
    if (auth.stage == ClientPanelStage.active) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed(DashboardScreen.routeName);
      });
    } else if (auth.stage == ClientPanelStage.pendingApproval) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(
          context,
        ).pushReplacementNamed(PendingApprovalPage.routeName);
      });
    } else if (auth.stage == ClientPanelStage.rejected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed(RejectionPage.routeName);
      });
    }
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final auth = context.read<AuthService>();
    try {
      await auth.registerClient(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        businessName: _businessNameController.text.trim(),
        contactPerson: _contactNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        location: _locationController.text.trim(),
        category: _selectedCategory ?? 'Other',
      );
      if (!mounted) return;
      // didChangeDependencies will route based on approval status
      // Typically will go to PendingApprovalPage after signup
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created. We will review and approve shortly.'),
        ),
      );
    } on FirebaseAuthException catch (_) {
      _showError(auth.errorMessage ?? 'Unable to create account.');
    } catch (_) {
      _showError(auth.errorMessage ?? 'Unable to create account.');
    }
  }

  void _showError(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 760;
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Card(
                  margin: EdgeInsets.symmetric(
                    horizontal: isWide ? 32 : 16,
                    vertical: isWide ? 32 : 16,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 32,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create your client workspace',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Submit your details to get access to Offora publishing tools. Our team will approve your account before offers go live.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 28),
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _businessNameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Business name',
                                    prefixIcon: Icon(
                                      Icons.store_mall_directory_outlined,
                                    ),
                                  ),
                                  textInputAction: TextInputAction.next,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Business name is required';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 18),
                                TextFormField(
                                  controller: _locationController,
                                  decoration: const InputDecoration(
                                    labelText:
                                        'Shop location (Area / Landmark)',
                                    prefixIcon:
                                        Icon(Icons.location_on_outlined),
                                  ),
                                  textInputAction: TextInputAction.next,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Shop location is required';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 18),
                                TextFormField(
                                  controller: _contactNameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Primary contact person',
                                    prefixIcon: Icon(Icons.person_outline),
                                  ),
                                  textInputAction: TextInputAction.next,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Contact name is required';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 18),
                                TextFormField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  decoration: const InputDecoration(
                                    labelText: 'Phone number',
                                    prefixIcon: Icon(Icons.phone_outlined),
                                  ),
                                  textInputAction: TextInputAction.next,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Phone number is required';
                                    }
                                    final digitsOnly = value.replaceAll(
                                      RegExp(r'[^0-9+]'),
                                      '',
                                    );
                                    if (digitsOnly.length < 7) {
                                      return 'Enter a valid phone number';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 18),
                                DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(
                                    labelText: 'Shop category',
                                    prefixIcon: Icon(Icons.category_outlined),
                                  ),
                                  items: _categories
                                      .map((c) => DropdownMenuItem(
                                            value: c,
                                            child: Text(c),
                                          ))
                                      .toList(),
                                  initialValue: _selectedCategory,
                                  onChanged: (v) => setState(() {
                                    _selectedCategory = v;
                                  }),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please select a category';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 18),
                                TextFormField(
                                  controller: _addressController,
                                  decoration: const InputDecoration(
                                    labelText: 'Complete address',
                                    prefixIcon: Icon(Icons.home_outlined),
                                  ),
                                  maxLines: 3,
                                  textInputAction: TextInputAction.newline,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Complete address is required';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 18),
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: const InputDecoration(
                                    labelText: 'Work email',
                                    prefixIcon: Icon(Icons.email_outlined),
                                  ),
                                  textInputAction: TextInputAction.next,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Email is required';
                                    }
                                    final emailRegex = RegExp(
                                      r'^([\w\.-]+)@([\w-]+)\.([\w-]{2,})$',
                                    );
                                    if (!emailRegex.hasMatch(value.trim())) {
                                      return 'Enter a valid email address';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 18),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    prefixIcon: const Icon(Icons.lock_outline),
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                      ),
                                    ),
                                  ),
                                  textInputAction: TextInputAction.next,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Password is required';
                                    }
                                    if (value.trim().length < 6) {
                                      return 'Password must be at least 6 characters';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 18),
                                TextFormField(
                                  controller: _confirmPasswordController,
                                  obscureText: _obscureConfirmPassword,
                                  decoration: InputDecoration(
                                    labelText: 'Confirm password',
                                    prefixIcon: const Icon(Icons.lock_outline),
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _obscureConfirmPassword =
                                              !_obscureConfirmPassword;
                                        });
                                      },
                                      icon: Icon(
                                        _obscureConfirmPassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                      ),
                                    ),
                                  ),
                                  textInputAction: TextInputAction.done,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please confirm your password';
                                    }
                                    if (value.trim() !=
                                        _passwordController.text.trim()) {
                                      return 'Passwords do not match';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 28),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed:
                                        auth.isBusy ? null : _handleSignup,
                                    child: auth.isBusy
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text('Submit for approval'),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Align(
                                  alignment: Alignment.center,
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text(
                                      'Already have an account? Sign in',
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
            );
          },
        ),
      ),
    );
  }
}
