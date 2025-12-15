import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/auth_service.dart';
import '../../../core/error_messages.dart';

class ClientProfileScreen extends StatefulWidget {
  const ClientProfileScreen({super.key});

  @override
  State<ClientProfileScreen> createState() => _ClientProfileScreenState();
}

class _ClientProfileScreenState extends State<ClientProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final darkBlue = const Color(0xFF1F477D);
  final brightGold = const Color(0xFFF0B84D);

  bool _isEditing = false;

  late TextEditingController _businessNameController;
  late TextEditingController _contactPersonController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _locationController;
  late TextEditingController _categoryController;
  late TextEditingController _gstController;
  late TextEditingController _shopLicenseController;
  late TextEditingController _businessRegController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final auth = context.read<AuthService>();
    final user = auth.currentUser;

    _businessNameController =
        TextEditingController(text: (user?.businessName ?? ''));
    _contactPersonController =
        TextEditingController(text: user?.contactPerson ?? '');
    _phoneController =
        TextEditingController(text: user?.phoneNumber ?? user?.phone ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _addressController = TextEditingController(text: user?.address ?? '');
    _locationController = TextEditingController(text: user?.location ?? '');
    _categoryController = TextEditingController(text: user?.category ?? '');
    _gstController = TextEditingController(text: user?.gstNumber ?? '');
    _shopLicenseController =
        TextEditingController(text: user?.shopLicenseNumber ?? '');
    _businessRegController =
        TextEditingController(text: user?.businessRegistrationNumber ?? '');
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _contactPersonController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _locationController.dispose();
    _categoryController.dispose();
    _gstController.dispose();
    _shopLicenseController.dispose();
    _businessRegController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final auth = context.read<AuthService>();
      final current = auth.currentUser;
      if (current == null) throw Exception('No current user');

      // Only allow updating Business Name and Contact Person from this screen
      final updates = {
        'businessName': _businessNameController.text.trim(),
        'contactPerson': _contactPersonController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final firestore = FirebaseFirestore.instance;

      // Update user's Firestore profile under 'users/{uid}' (merge)
      await firestore
          .collection('users')
          .doc(current.uid)
          .set(updates, SetOptions(merge: true));

      // Also update top-level 'clients/{uid}' document if present
      await firestore
          .collection('clients')
          .doc(current.uid)
          .set(updates, SetOptions(merge: true));

      // Refresh local auth profile cache
      await auth.refreshProfile();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );

      setState(() => _isEditing = false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ErrorMessages.friendlyErrorMessage(e))),
      );
    } finally {
      if (mounted) {}
    }
  }

  void _cancelEditing() {
    setState(() => _isEditing = false);
    _initializeControllers();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final user = auth.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return SafeArea(
      child: Container(
        color: const Color(0xFFF5F7FA),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Profile header card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      darkBlue,
                      // Replace deprecated withOpacity with withValues
                      darkBlue.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: darkBlue.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: brightGold,
                      child: Text(
                        (user.businessName.isNotEmpty
                                ? user.businessName[0]
                                : 'B')
                            .toUpperCase(),
                        style: TextStyle(
                          color: darkBlue,
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      (user.businessName.isNotEmpty
                          ? user.businessName
                          : 'Business Name'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      (user.category.isNotEmpty ? user.category : 'Category'),
                      style: TextStyle(
                        color: brightGold,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Edit / Save controls (moved here since AppBar is shared)
              Padding(
                padding: const EdgeInsets.only(right: 4, top: 8, bottom: 8),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: !_isEditing
                      ? IconButton(
                          icon: const Icon(Icons.edit),
                          color: darkBlue,
                          onPressed: () => setState(() => _isEditing = true),
                          tooltip: 'Edit Profile',
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                              onPressed: _cancelEditing,
                              style: TextButton.styleFrom(
                                  foregroundColor: darkBlue),
                              child: const Text('Cancel'),
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: _saveProfile,
                              style: TextButton.styleFrom(
                                  foregroundColor: darkBlue,
                                  textStyle: const TextStyle(
                                      fontWeight: FontWeight.w700)),
                              child: const Text('Save'),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 12),

              // Business Information
              _SectionHeader(
                title: 'Business Information',
                icon: Icons.business,
                darkBlue: darkBlue,
              ),
              const SizedBox(height: 12),
              _ProfileField(
                label: 'Business Name',
                controller: _businessNameController,
                icon: Icons.store,
                enabled: _isEditing,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Business name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _ProfileField(
                label: 'Category',
                controller: _categoryController,
                icon: Icons.category,
                enabled: false,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Category is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _ProfileField(
                label: 'Contact Person',
                controller: _contactPersonController,
                icon: Icons.person,
                enabled: _isEditing,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Contact person is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Contact Information
              _SectionHeader(
                title: 'Contact Information',
                icon: Icons.contact_phone,
                darkBlue: darkBlue,
              ),
              const SizedBox(height: 12),
              _ProfileField(
                label: 'Phone Number',
                controller: _phoneController,
                icon: Icons.phone,
                enabled: false,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Phone number is required';
                  }
                  if (value.trim().length != 10) {
                    return 'Phone number must be 10 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _ProfileField(
                label: 'Email',
                controller: _emailController,
                icon: Icons.email,
                enabled: false, // Email cannot be changed
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              _ProfileField(
                label: 'Address',
                controller: _addressController,
                icon: Icons.home,
                enabled: false,
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Address is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _ProfileField(
                label: 'Location',
                controller: _locationController,
                icon: Icons.location_on,
                enabled: false,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Location is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Legal Information
              _SectionHeader(
                title: 'Legal Information',
                icon: Icons.gavel,
                darkBlue: darkBlue,
              ),
              const SizedBox(height: 12),
              _ProfileField(
                label: 'GST Number',
                controller: _gstController,
                icon: Icons.receipt_long,
                enabled: false,
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 12),
              _ProfileField(
                label: 'Shop License Number',
                controller: _shopLicenseController,
                icon: Icons.badge,
                enabled: false,
              ),
              const SizedBox(height: 12),
              _ProfileField(
                label: 'Business Registration Number',
                controller: _businessRegController,
                icon: Icons.business_center,
                enabled: false,
              ),
              const SizedBox(height: 32),

              // Logout button
              if (!_isEditing)
                OutlinedButton.icon(
                  onPressed: () async {
                    final navigator = Navigator.of(context);
                    final authService = context.read<AuthService>();
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: Colors.white,
                        title: const Text('Logout',
                            style: TextStyle(color: Colors.black)),
                        content: const Text('Are you sure you want to logout?',
                            style: TextStyle(color: Colors.black)),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel',
                                style: TextStyle(color: Colors.black)),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Logout',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    );
                    if (!mounted) return;
                    if (confirmed != true) return;
                    await authService.signOut();
                    if (!mounted) return;
                    navigator.pushNamedAndRemoveUntil(
                      '/',
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.logout, color: Color(0xFF1F477D)),
                  label: const Text('Logout',
                      style: TextStyle(color: Color(0xFF1F477D))),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1F477D),
                    side: const BorderSide(color: Color(0xFF1F477D)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color darkBlue;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.darkBlue,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: darkBlue, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: darkBlue,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _ProfileField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final bool enabled;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final int maxLines;
  final String? Function(String?)? validator;

  const _ProfileField({
    required this.label,
    required this.controller,
    required this.icon,
    this.enabled = true,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      maxLines: maxLines,
      validator: validator,
      style: TextStyle(
        color: enabled ? Colors.black87 : Colors.grey.shade600,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: enabled ? const Color(0xFF1F477D) : Colors.grey.shade500,
        ),
        prefixIcon: Icon(
          icon,
          color: enabled ? const Color(0xFF1F477D) : Colors.grey.shade400,
        ),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1F477D), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }
}
