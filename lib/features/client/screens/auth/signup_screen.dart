import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../shared/models/client_panel_stage.dart';
import '../../../../shared/services/auth_service.dart';
import '../../../../core/errors/error_messages.dart';
import '../../../../shared/widgets/responsive_page.dart';
import '../../../../core/utils/keyboard_utils.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  static const String routeName = '/signup';

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
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

  // Focus nodes for proper keyboard handling
  final _businessNameFocus = FocusNode();
  final _locationFocus = FocusNode();
  final _contactNameFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _addressFocus = FocusNode();
  final _cityFocus = FocusNode();
  final _gstFocus = FocusNode();
  final _shopLicenseFocus = FocusNode();
  final _registrationFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

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
    'Construction',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _fetchCities();
    // Add focus listeners for all fields to ensure scroll visibility
    _businessNameFocus
        .addListener(() => _handleFocusChange(_businessNameFocus));
    _locationFocus.addListener(() => _handleFocusChange(_locationFocus));
    _contactNameFocus.addListener(() => _handleFocusChange(_contactNameFocus));
    _phoneFocus.addListener(_onPhoneFocusChange);
    _addressFocus.addListener(() => _handleFocusChange(_addressFocus));
    _cityFocus.addListener(() => _handleFocusChange(_cityFocus));
    _gstFocus.addListener(() => _handleFocusChange(_gstFocus));
    _shopLicenseFocus.addListener(() => _handleFocusChange(_shopLicenseFocus));
    _registrationFocus
        .addListener(() => _handleFocusChange(_registrationFocus));
    _emailFocus.addListener(() => _handleFocusChange(_emailFocus));
    _passwordFocus.addListener(_onPasswordFocusChange);
    _confirmPasswordFocus.addListener(_onConfirmPasswordFocusChange);
  }

  void _handleFocusChange(FocusNode focusNode) {
    if (focusNode.hasFocus) {
      _scrollToFocused(focusNode);
    }
  }

  void _onPhoneFocusChange() {
    if (_phoneFocus.hasFocus) {
      _scrollToFocused(_phoneFocus);
    }
  }

  void _onPasswordFocusChange() {
    if (_passwordFocus.hasFocus) {
      _scrollToFocused(_passwordFocus);
    }
  }

  void _onConfirmPasswordFocusChange() {
    if (_confirmPasswordFocus.hasFocus) {
      _scrollToFocused(_confirmPasswordFocus);
    }
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
    // Remove focus listeners before disposing
    _phoneFocus.removeListener(_onPhoneFocusChange);
    _passwordFocus.removeListener(_onPasswordFocusChange);
    _confirmPasswordFocus.removeListener(_onConfirmPasswordFocusChange);

    _scrollController.dispose();
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
    // Dispose focus nodes
    _businessNameFocus.dispose();
    _locationFocus.dispose();
    _contactNameFocus.dispose();
    _phoneFocus.dispose();
    _addressFocus.dispose();
    _cityFocus.dispose();
    _gstFocus.dispose();
    _shopLicenseFocus.dispose();
    _registrationFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    // Reset redirect flag when attempting new signup
    _hasRedirected = false;

    final auth = Provider.of<AuthService>(context, listen: false);
    try {
      // Format phone number with +91 prefix
      final phoneDigits =
          _phoneController.text.trim().replaceAll(RegExp(r'[^0-9]'), '');
      final formattedPhone = '+91$phoneDigits';

      await auth.registerClient(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        businessName: _businessNameController.text.trim(),
        contactPerson: _contactNameController.text.trim(),
        phoneNumber: formattedPhone,
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
        // Use go to navigate to pending approval
        context.go('/pending-approval');
      } else if (auth.stage == ClientPanelStage.active) {
        // Use go to navigate to dashboard
        context.go('/client-dashboard');
      } else if (auth.stage == ClientPanelStage.rejected) {
        // Use go to navigate to rejection
        context.go('/rejection');
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
      child: GestureDetector(
        onTap: () => KeyboardUtils.dismissKeyboard(context),
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.white,
          body: SafeArea(
            child: ResponsivePage(
              padding: EdgeInsets.zero,
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
                      Center(
                        child: ConstrainedBox(
                          constraints:
                              BoxConstraints(maxWidth: isWide ? 720 : 560),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: isWide ? 28 : 8, vertical: 8),
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
                                    horizontal: 16, vertical: 16),
                                child: SingleChildScrollView(
                                  controller: _scrollController,
                                  keyboardDismissBehavior:
                                      ScrollViewKeyboardDismissBehavior.onDrag,
                                  physics: const ClampingScrollPhysics(),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Back button row
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: GestureDetector(
                                          onTap: () =>
                                              context.go('/client-login'),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.arrow_back,
                                                color: darkBlue,
                                                size: 24,
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                'Back to Login',
                                                style: TextStyle(
                                                  color: darkBlue,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
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
                                                      offset:
                                                          const Offset(0, 6),
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
                                                focusNode: _businessNameFocus,
                                                label: 'Business name',
                                                icon: Icons
                                                    .store_mall_directory_outlined,
                                                onFieldSubmitted: (_) =>
                                                    _locationFocus
                                                        .requestFocus(),
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
                                                focusNode: _locationFocus,
                                                label:
                                                    'Shop location (Area / Landmark)',
                                                icon:
                                                    Icons.location_on_outlined,
                                                onFieldSubmitted: (_) =>
                                                    _contactNameFocus
                                                        .requestFocus(),
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
                                                focusNode: _contactNameFocus,
                                                label:
                                                    'Primary contact person Name',
                                                icon: Icons.person_outline,
                                                onFieldSubmitted: (_) =>
                                                    _phoneFocus.requestFocus(),
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.trim().isEmpty) {
                                                    return 'Contact name is required';
                                                  }
                                                  return null;
                                                },
                                              ),
                                              const SizedBox(height: 14),
                                              TextFormField(
                                                controller: _phoneController,
                                                focusNode: _phoneFocus,
                                                keyboardType:
                                                    TextInputType.phone,
                                                maxLength: 10,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .digitsOnly,
                                                  LengthLimitingTextInputFormatter(
                                                      10),
                                                ],
                                                style: const TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                cursorColor:
                                                    const Color(0xFF1F477D),
                                                decoration: InputDecoration(
                                                  labelText: 'Phone number',
                                                  labelStyle: const TextStyle(
                                                    color: Color(0xFF666666),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  prefixIcon: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 12),
                                                    child: const Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                          '+91',
                                                          style: TextStyle(
                                                            color: Color(
                                                                0xFF1F477D),
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 15,
                                                          ),
                                                        ),
                                                        SizedBox(width: 8),
                                                        Text(
                                                          '|',
                                                          style: TextStyle(
                                                            color: Color(
                                                                0xFFE0E0E0),
                                                            fontSize: 20,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  prefixIconConstraints:
                                                      const BoxConstraints(
                                                          minWidth: 0,
                                                          minHeight: 0),
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    borderSide:
                                                        const BorderSide(
                                                      color: Color(0xFFE0E0E0),
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
                                                      color: Color(0xFF1F477D),
                                                      width: 2,
                                                    ),
                                                  ),
                                                  errorBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    borderSide:
                                                        const BorderSide(
                                                      color: Colors.red,
                                                      width: 1.5,
                                                    ),
                                                  ),
                                                  focusedErrorBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    borderSide:
                                                        const BorderSide(
                                                      color: Colors.red,
                                                      width: 2,
                                                    ),
                                                  ),
                                                ),
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.trim().isEmpty) {
                                                    return 'Phone number is required';
                                                  }
                                                  final digitsOnly =
                                                      value.replaceAll(
                                                          RegExp(r'[^0-9]'),
                                                          '');
                                                  if (digitsOnly.length != 10) {
                                                    return 'Enter a valid 10-digit phone number';
                                                  }
                                                  return null;
                                                },
                                                textInputAction:
                                                    TextInputAction.next,
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
                                                        BorderRadius.circular(
                                                            12),
                                                    borderSide:
                                                        const BorderSide(
                                                      color: Color(0xFFE0E0E0),
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
                                                    .map((c) =>
                                                        DropdownMenuItem(
                                                            value: c,
                                                            child: Text(c)))
                                                    .toList(),
                                                initialValue: _selectedCategory,
                                                onChanged: (v) => setState(() =>
                                                    _selectedCategory = v),
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
                                                focusNode: _addressFocus,
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
                                                optionsBuilder:
                                                    (TextEditingValue
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
                                                        _cityController
                                                            .selection;
                                                  }
                                                  // Attach a single listener and store it so it can be removed on dispose
                                                  if (_autocompleteListener ==
                                                      null) {
                                                    _autocompleteListener = () {
                                                      if (_autocompleteCityController !=
                                                              null &&
                                                          _cityController
                                                                  .text !=
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
                                                          color: Color(
                                                              0xFF1F477D)),
                                                      filled: true,
                                                      fillColor: Colors.white,
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
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
                                                            BorderRadius
                                                                .circular(12),
                                                        borderSide:
                                                            const BorderSide(
                                                          color:
                                                              Color(0xFF1F477D),
                                                          width: 2,
                                                        ),
                                                      ),
                                                    ),
                                                    validator: (v) => v ==
                                                                null ||
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
                                                    alignment:
                                                        Alignment.topLeft,
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
                                                            final option =
                                                                options
                                                                    .elementAt(
                                                                        index);
                                                            return ListTile(
                                                              dense: true,
                                                              title: Text(
                                                                  option,
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
                                                style: theme
                                                    .textTheme.labelLarge
                                                    ?.copyWith(
                                                  color:
                                                      const Color(0xFF1F477D),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              _styledField(
                                                controller:
                                                    _gstNumberController,
                                                label: 'GST Number',
                                                icon: Icons.receipt_outlined,
                                                keyboardType:
                                                    TextInputType.text,
                                              ),
                                              const SizedBox(height: 14),
                                              _styledField(
                                                controller:
                                                    _shopLicenseController,
                                                label: 'Shop License Number',
                                                icon: Icons.card_giftcard,
                                                keyboardType:
                                                    TextInputType.text,
                                              ),
                                              const SizedBox(height: 14),
                                              _styledField(
                                                controller:
                                                    _registrationNumberController,
                                                label:
                                                    'Business Registration Number',
                                                icon:
                                                    Icons.description_outlined,
                                                keyboardType:
                                                    TextInputType.text,
                                              ),
                                              const SizedBox(height: 20),
                                              _styledField(
                                                controller: _emailController,
                                                focusNode: _emailFocus,
                                                label: 'Work email',
                                                icon: Icons.email_outlined,
                                                keyboardType:
                                                    TextInputType.emailAddress,
                                                onFieldSubmitted: (_) =>
                                                    _passwordFocus
                                                        .requestFocus(),
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
                                                focusNode: _passwordFocus,
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
                                                      color: const Color(
                                                          0xFF1F477D),
                                                    ),
                                                  ),
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    borderSide:
                                                        const BorderSide(
                                                      color: Color(0xFFE0E0E0),
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
                                                      color: Color(0xFF1F477D),
                                                      width: 2,
                                                    ),
                                                  ),
                                                  errorBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    borderSide:
                                                        const BorderSide(
                                                      color: Colors.red,
                                                      width: 1.5,
                                                    ),
                                                  ),
                                                  focusedErrorBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    borderSide:
                                                        const BorderSide(
                                                      color: Colors.red,
                                                      width: 2,
                                                    ),
                                                  ),
                                                ),
                                                textInputAction:
                                                    TextInputAction.next,
                                                onFieldSubmitted: (_) =>
                                                    _confirmPasswordFocus
                                                        .requestFocus(),
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
                                                focusNode:
                                                    _confirmPasswordFocus,
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
                                                      color: const Color(
                                                          0xFF1F477D),
                                                    ),
                                                  ),
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    borderSide:
                                                        const BorderSide(
                                                      color: Color(0xFFE0E0E0),
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
                                                      color: Color(0xFF1F477D),
                                                      width: 2,
                                                    ),
                                                  ),
                                                  errorBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    borderSide:
                                                        const BorderSide(
                                                      color: Colors.red,
                                                      width: 1.5,
                                                    ),
                                                  ),
                                                  focusedErrorBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    borderSide:
                                                        const BorderSide(
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
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor: darkBlue,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12)),
                                                    elevation: 6,
                                                  ),
                                                  child: auth.isBusy
                                                      ? const SizedBox(
                                                          height: 20,
                                                          width: 20,
                                                          child:
                                                              CircularProgressIndicator(
                                                                  strokeWidth:
                                                                      2,
                                                                  color:
                                                                      Colors
                                                                          .white))
                                                      : Text(
                                                          'Submit for approval',
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
                                                      Navigator.of(context)
                                                          .pop(),
                                                  child: const Text(
                                                      'Already have an account? Sign in'),
                                                ),
                                              ),
                                              // Add bottom padding for keyboard
                                              const KeyboardBottomPadding(
                                                  minPadding: 20),
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
      ),
    );
  }

  // Helper method to scroll to a specific widget
  void _scrollToFocused(FocusNode? focusNode) {
    if (focusNode == null) return;
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted && focusNode.context != null) {
        Scrollable.ensureVisible(
          focusNode.context!,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: 0.5,
        );
      }
    });
  }

  // Small helper to keep input styling consistent
  Widget _styledField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
    FocusNode? focusNode,
    void Function(String)? onFieldSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
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
      onFieldSubmitted: onFieldSubmitted,
    );
  }
}
