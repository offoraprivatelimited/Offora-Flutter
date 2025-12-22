import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../models/client_panel_stage.dart';
import '../../../services/auth_service.dart';
import '../../../core/error_messages.dart';
import '../../../widgets/responsive_page.dart';

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
  final _gstNumberController = TextEditingController();
  final _shopLicenseController = TextEditingController();
  final _registrationNumberController = TextEditingController();
  final _cityController = TextEditingController();
  TextEditingController? _autocompleteCityController;
  VoidCallback? _autocompleteListener;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _selectedCategory;
  bool _hasRedirected = false;

  List<String> _citySuggestions = [];
  bool _loadingCities = false;

  final List<String> _categories = const [
    // Consolidated Food Categories
    'Grocery',
    'Supermarket',
    'Restaurant',
    'Cafe & Bakery', // Consolidated category

    // Other Existing Categories
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
  void initState() {
    super.initState();
    _fetchCities();
  }

  Future<void> _fetchCities() async {
    setState(() {
      _loadingCities = true;
    });
    try {
      // Remove unused/invalid 'response' and 'await' on Uri
      final res =
          await Future.delayed(const Duration(milliseconds: 500), () async {
        return await http.post(
          Uri.parse('https://countriesnow.space/api/v0.1/countries/cities'),
          headers: {'Content-Type': 'application/json'},
          body: '{"country": "India"}',
        );
      });
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final List<dynamic> cities = data['data'] ?? [];
        setState(() {
          _citySuggestions = List<String>.from(cities);
        });
      }
    } catch (e) {
      setState(() {
        _citySuggestions = [];
      });
    } finally {
      setState(() {
        _loadingCities = false;
      });
    }
  }

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
    _gstNumberController.dispose();
    _shopLicenseController.dispose();
    _registrationNumberController.dispose();
    _cityController.dispose();
    if (_autocompleteCityController != null && _autocompleteListener != null) {
      try {
        _autocompleteCityController!.removeListener(_autocompleteListener!);
      } catch (_) {}
      _autocompleteListener = null;
      _autocompleteCityController = null;
    }
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    // Reset redirect flag when attempting new signup
    _hasRedirected = false;

    final auth = Provider.of<AuthService>(context, listen: false);
    try {
      await auth.registerClient(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        businessName: _businessNameController.text.trim(),
        contactPerson: _contactNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        location: _locationController.text.trim(),
        city: _cityController.text.trim(),
        category: _selectedCategory ?? 'Other',
        gstNumber: _gstNumberController.text.trim().isEmpty
            ? null
            : _gstNumberController.text.trim(),
        shopLicenseNumber: _shopLicenseController.text.trim().isEmpty
            ? null
            : _shopLicenseController.text.trim(),
        businessRegistrationNumber:
            _registrationNumberController.text.trim().isEmpty
                ? null
                : _registrationNumberController.text.trim(),
      );

      // Refresh profile to get the most current stage information
      await auth.refreshProfile();

      if (!mounted) return;

      // Only redirect once
      if (_hasRedirected) return;
      _hasRedirected = true;

      // Route based on approval stage
      if (auth.stage == ClientPanelStage.pendingApproval) {
        context.pushReplacementNamed('pending-approval');
      } else if (auth.stage == ClientPanelStage.active) {
        context.pushReplacementNamed('client-dashboard');
      } else if (auth.stage == ClientPanelStage.rejected) {
        context.pushReplacementNamed('rejection');
      }
    } catch (e) {
      if (!mounted) return;
      _hasRedirected = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ErrorMessages.friendlyErrorMessage(e)),
          backgroundColor: Colors.red.shade600,
        ),
      );
      debugPrint('[SignupScreen] Signup error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = Provider.of<AuthService>(context);

    // Premium colors
    const darkBlue = Color(0xFF1F477D);
    const brightGold = Color(0xFFF0B84D);
    const darkerGold = Color(0xFFA3834D);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        // Prevent back navigation
        if (didPop) return;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        body: SafeArea(
          child: ResponsivePage(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 760;
                return Stack(
                  children: [
                    Positioned(
                      top: -constraints.maxWidth * 0.25,
                      left: -constraints.maxWidth * 0.18,
                      child: Container(
                        width: constraints.maxWidth * 0.9,
                        height: constraints.maxWidth * 0.9,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              darkBlue.withAlpha(253),
                              darkBlue.withAlpha(153)
                            ],
                            center: Alignment.topLeft,
                            radius: 0.8,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: -constraints.maxWidth * 0.12,
                      right: -constraints.maxWidth * 0.22,
                      child: Container(
                        width: constraints.maxWidth * 0.68,
                        height: constraints.maxWidth * 0.68,
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
                    Positioned(
                      bottom: -constraints.maxWidth * 0.22,
                      left: -constraints.maxWidth * 0.18,
                      child: Container(
                        width: constraints.maxWidth * 1.2,
                        height: constraints.maxWidth * 0.9,
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(constraints.maxWidth),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              darkerGold.withAlpha(46),
                              Colors.transparent
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 32,
                      left: 16,
                      child: Material(
                        color: Colors.transparent,
                        elevation: 4,
                        shape: const CircleBorder(),
                        child: IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back,
                              color: Color(0xFF1F477D), size: 28),
                          tooltip: 'Back',
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                    ),
                    Center(
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(maxWidth: isWide ? 720 : 560),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: isWide ? 28 : 16, vertical: 28),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(250),
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
                                  horizontal: 28, vertical: 28),
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Create your client workspace',
                                                style: theme
                                                    .textTheme.headlineSmall
                                                    ?.copyWith(
                                                  fontWeight: FontWeight.w800,
                                                  color: darkBlue,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                'Submit your details to get access to Offora publishing tools. Our team will approve your account before offers go live.',
                                                style: theme
                                                    .textTheme.bodyMedium
                                                    ?.copyWith(
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Stack(
                                          alignment: Alignment.topRight,
                                          children: [
                                            Container(
                                              width: 90,
                                              height: 90,
                                              decoration: BoxDecoration(
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: darkerGold
                                                        .withAlpha(56),
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
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    Center(
                                      child: Form(
                                        key: _formKey,
                                        child: Column(
                                          children: [
                                            _styledField(
                                              controller:
                                                  _businessNameController,
                                              label: 'Business name',
                                              icon: Icons
                                                  .store_mall_directory_outlined,
                                              validator: (value) {
                                                if (value == null ||
                                                    value.trim().isEmpty) {
                                                  return 'Business name is required';
                                                }
                                                return null;
                                              },
                                            ),
                                            const SizedBox(height: 14),
                                            _styledField(
                                              controller: _locationController,
                                              label:
                                                  'Shop location (Area / Landmark)',
                                              icon: Icons.location_on_outlined,
                                              validator: (value) {
                                                if (value == null ||
                                                    value.trim().isEmpty) {
                                                  return 'Shop location is required';
                                                }
                                                return null;
                                              },
                                            ),
                                            const SizedBox(height: 14),
                                            _styledField(
                                              controller:
                                                  _contactNameController,
                                              label: 'Primary contact person',
                                              icon: Icons.person_outline,
                                              validator: (value) {
                                                if (value == null ||
                                                    value.trim().isEmpty) {
                                                  return 'Contact name is required';
                                                }
                                                return null;
                                              },
                                            ),
                                            const SizedBox(height: 14),
                                            _styledField(
                                              controller: _phoneController,
                                              label: 'Phone number',
                                              icon: Icons.phone_outlined,
                                              keyboardType: TextInputType.phone,
                                              validator: (value) {
                                                if (value == null ||
                                                    value.trim().isEmpty) {
                                                  return 'Phone number is required';
                                                }
                                                final digitsOnly =
                                                    value.replaceAll(
                                                        RegExp(r'[^0-9+]'), '');
                                                if (digitsOnly.length < 7) {
                                                  return 'Enter a valid phone number';
                                                }
                                                return null;
                                              },
                                            ),
                                            const SizedBox(height: 14),
                                            DropdownButtonFormField<String>(
                                              decoration: InputDecoration(
                                                labelText: 'Shop category',
                                                labelStyle: const TextStyle(
                                                  color: Color(0xFF666666),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                filled: true,
                                                fillColor: Colors.white,
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  borderSide: const BorderSide(
                                                    color: Color(0xFFE0E0E0),
                                                    width: 1.5,
                                                  ),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  borderSide: const BorderSide(
                                                    color: Color(0xFF1F477D),
                                                    width: 2,
                                                  ),
                                                ),
                                              ),
                                              style: const TextStyle(
                                                color: Colors.black87,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              items: _categories
                                                  .map((c) => DropdownMenuItem(
                                                      value: c, child: Text(c)))
                                                  .toList(),
                                              initialValue: _selectedCategory,
                                              onChanged: (v) => setState(
                                                  () => _selectedCategory = v),
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Please select a category';
                                                }
                                                return null;
                                              },
                                            ),
                                            const SizedBox(height: 14),
                                            _styledField(
                                              controller: _addressController,
                                              label: 'Complete address',
                                              icon: Icons.home_outlined,
                                              maxLines: 3,
                                              validator: (value) {
                                                if (value == null ||
                                                    value.trim().isEmpty) {
                                                  return 'Complete address is required';
                                                }
                                                return null;
                                              },
                                            ),
                                            const SizedBox(height: 14),
                                            // City Autocomplete Field
                                            Autocomplete<String>(
                                              optionsBuilder: (TextEditingValue
                                                  textEditingValue) {
                                                if (_loadingCities ||
                                                    textEditingValue
                                                        .text.isEmpty) {
                                                  return const Iterable<
                                                      String>.empty();
                                                }
                                                return _citySuggestions.where(
                                                    (city) => city
                                                        .toLowerCase()
                                                        .contains(
                                                            textEditingValue
                                                                .text
                                                                .toLowerCase()));
                                              },
                                              fieldViewBuilder: (context,
                                                  cityFieldController,
                                                  focusNode,
                                                  onFieldSubmitted) {
                                                // Keep a single listener attached to the Autocomplete controller so
                                                // the typed text is kept in sync with our _cityController used
                                                // by the form submission.
                                                _autocompleteCityController ??=
                                                    cityFieldController;
                                                // initialize content
                                                if (_autocompleteCityController!
                                                        .text !=
                                                    _cityController.text) {
                                                  _autocompleteCityController!
                                                          .text =
                                                      _cityController.text;
                                                  _autocompleteCityController!
                                                          .selection =
                                                      _cityController.selection;
                                                }
                                                // Attach a single listener and store it so it can be removed on dispose
                                                if (_autocompleteListener ==
                                                    null) {
                                                  _autocompleteListener = () {
                                                    if (_autocompleteCityController !=
                                                            null &&
                                                        _cityController.text !=
                                                            _autocompleteCityController!
                                                                .text) {
                                                      _cityController.text =
                                                          _autocompleteCityController!
                                                              .text;
                                                      _cityController
                                                              .selection =
                                                          _autocompleteCityController!
                                                              .selection;
                                                    }
                                                  };
                                                  _autocompleteCityController!
                                                      .addListener(
                                                          _autocompleteListener!);
                                                }
                                                return TextFormField(
                                                  controller:
                                                      cityFieldController,
                                                  focusNode: focusNode,
                                                  style: const TextStyle(
                                                      color: Colors.black),
                                                  decoration: InputDecoration(
                                                    labelText: 'City',
                                                    prefixIcon: const Icon(
                                                        Icons
                                                            .location_city_outlined,
                                                        color:
                                                            Color(0xFF1F477D)),
                                                    filled: true,
                                                    fillColor: Colors.white,
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      borderSide:
                                                          const BorderSide(
                                                        color:
                                                            Color(0xFFE0E0E0),
                                                        width: 1.5,
                                                      ),
                                                    ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      borderSide:
                                                          const BorderSide(
                                                        color:
                                                            Color(0xFF1F477D),
                                                        width: 2,
                                                      ),
                                                    ),
                                                  ),
                                                  validator: (v) => v == null ||
                                                          v.isEmpty
                                                      ? 'Please enter your city'
                                                      : null,
                                                );
                                              },
                                              onSelected: (String selection) {
                                                _cityController.text =
                                                    selection;
                                              },
                                              optionsViewBuilder: (context,
                                                  onSelected, options) {
                                                // Custom suggestions list with black text for readability
                                                return Align(
                                                  alignment: Alignment.topLeft,
                                                  child: Material(
                                                    elevation: 4,
                                                    child: Container(
                                                      constraints:
                                                          const BoxConstraints(
                                                              maxHeight: 220),
                                                      color: Colors.white,
                                                      child: ListView.builder(
                                                        padding:
                                                            EdgeInsets.zero,
                                                        shrinkWrap: true,
                                                        itemCount:
                                                            options.length,
                                                        itemBuilder:
                                                            (context, index) {
                                                          final option = options
                                                              .elementAt(index);
                                                          return ListTile(
                                                            dense: true,
                                                            title: Text(option,
                                                                style: const TextStyle(
                                                                    color: Colors
                                                                        .black)),
                                                            onTap: () =>
                                                                onSelected(
                                                                    option),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                            const SizedBox(height: 20),
                                            // Optional Business Registration Details
                                            Text(
                                              'Business Registration (Optional)',
                                              style: theme.textTheme.labelLarge
                                                  ?.copyWith(
                                                color: const Color(0xFF1F477D),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            _styledField(
                                              controller: _gstNumberController,
                                              label: 'GST Number',
                                              icon: Icons.receipt_outlined,
                                              keyboardType: TextInputType.text,
                                            ),
                                            const SizedBox(height: 14),
                                            _styledField(
                                              controller:
                                                  _shopLicenseController,
                                              label: 'Shop License Number',
                                              icon: Icons.card_giftcard,
                                              keyboardType: TextInputType.text,
                                            ),
                                            const SizedBox(height: 14),
                                            _styledField(
                                              controller:
                                                  _registrationNumberController,
                                              label:
                                                  'Business Registration Number',
                                              icon: Icons.description_outlined,
                                              keyboardType: TextInputType.text,
                                            ),
                                            const SizedBox(height: 20),
                                            _styledField(
                                              controller: _emailController,
                                              label: 'Work email',
                                              icon: Icons.email_outlined,
                                              keyboardType:
                                                  TextInputType.emailAddress,
                                              validator: (value) {
                                                if (value == null ||
                                                    value.trim().isEmpty) {
                                                  return 'Email is required';
                                                }
                                                final emailRegex = RegExp(
                                                    r'^([\w\.-]+)@([\w-]+)\.([\w-]{2,})$');
                                                if (!emailRegex
                                                    .hasMatch(value.trim())) {
                                                  return 'Enter a valid email address';
                                                }
                                                return null;
                                              },
                                            ),
                                            const SizedBox(height: 14),
                                            TextFormField(
                                              controller: _passwordController,
                                              obscureText: _obscurePassword,
                                              style: const TextStyle(
                                                color: Colors.black87,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              cursorColor:
                                                  const Color(0xFF1F477D),
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
                                                  onPressed: () => setState(
                                                      () => _obscurePassword =
                                                          !_obscurePassword),
                                                  icon: Icon(
                                                    _obscurePassword
                                                        ? Icons
                                                            .visibility_off_outlined
                                                        : Icons
                                                            .visibility_outlined,
                                                    color:
                                                        const Color(0xFF1F477D),
                                                  ),
                                                ),
                                                filled: true,
                                                fillColor: Colors.white,
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  borderSide: const BorderSide(
                                                    color: Color(0xFFE0E0E0),
                                                    width: 1.5,
                                                  ),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  borderSide: const BorderSide(
                                                    color: Color(0xFF1F477D),
                                                    width: 2,
                                                  ),
                                                ),
                                              ),
                                              textInputAction:
                                                  TextInputAction.next,
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
                                            ),
                                            const SizedBox(height: 14),
                                            TextFormField(
                                              controller:
                                                  _confirmPasswordController,
                                              obscureText:
                                                  _obscureConfirmPassword,
                                              style: const TextStyle(
                                                color: Colors.black87,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              cursorColor:
                                                  const Color(0xFF1F477D),
                                              decoration: InputDecoration(
                                                labelText: 'Confirm password',
                                                labelStyle: const TextStyle(
                                                  color: Color(0xFF666666),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                prefixIcon: const Icon(
                                                    Icons.lock_outline,
                                                    color: Color(0xFF1F477D)),
                                                suffixIcon: IconButton(
                                                  onPressed: () => setState(() =>
                                                      _obscureConfirmPassword =
                                                          !_obscureConfirmPassword),
                                                  icon: Icon(
                                                    _obscureConfirmPassword
                                                        ? Icons
                                                            .visibility_off_outlined
                                                        : Icons
                                                            .visibility_outlined,
                                                    color:
                                                        const Color(0xFF1F477D),
                                                  ),
                                                ),
                                                filled: true,
                                                fillColor: Colors.white,
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  borderSide: const BorderSide(
                                                    color: Color(0xFFE0E0E0),
                                                    width: 1.5,
                                                  ),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  borderSide: const BorderSide(
                                                    color: Color(0xFF1F477D),
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
                                              textInputAction:
                                                  TextInputAction.done,
                                              validator: (value) {
                                                if (value == null ||
                                                    value.trim().isEmpty) {
                                                  return 'Please confirm your password';
                                                }
                                                if (value.trim() !=
                                                    _passwordController.text
                                                        .trim()) {
                                                  return 'Passwords do not match';
                                                }
                                                return null;
                                              },
                                            ),
                                            const SizedBox(height: 22),
                                            SizedBox(
                                              width: double.infinity,
                                              height: 54,
                                              child: ElevatedButton(
                                                onPressed: auth.isBusy
                                                    ? null
                                                    : _handleSignup,
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: darkBlue,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12)),
                                                  elevation: 6,
                                                ),
                                                child: auth.isBusy
                                                    ? const SizedBox(
                                                        height: 20,
                                                        width: 20,
                                                        child:
                                                            CircularProgressIndicator(
                                                                strokeWidth: 2,
                                                                color: Colors
                                                                    .white))
                                                    : Text('Submit for approval',
                                                        style: theme.textTheme
                                                            .labelLarge
                                                            ?.copyWith(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700)),
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            Align(
                                              alignment: Alignment.center,
                                              child: TextButton(
                                                onPressed: () =>
                                                    Navigator.of(context).pop(),
                                                child: const Text(
                                                    'Already have an account? Sign in'),
                                              ),
                                            ),
                                          ],
                                        ),
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
              },
            ),
          ),
        ),
      ),
    );
  }

  // Small helper to keep input styling consistent
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
      keyboardType: maxLines > 1 ? TextInputType.multiline : keyboardType,
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
        prefixIcon: const Icon(null),
        prefixIconConstraints: const BoxConstraints(),
        prefixText: '  ',
        prefixStyle: const TextStyle(fontSize: 0),
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
      textInputAction:
          maxLines > 1 ? TextInputAction.newline : TextInputAction.next,
    );
  }
}
