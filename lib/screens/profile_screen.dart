import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import '../widgets/app_drawer.dart';
import '../theme/colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  XFile? _profileImage;
  Uint8List? _imageBytes;
  String? _initialPhotoUrl;
  bool _isSaving = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthService>().currentUser;
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
      _initialPhotoUrl = user.photoUrl;
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _profileImage = pickedFile;
        _imageBytes = bytes;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      _showMessage('Name cannot be empty.');
      return;
    }

    setState(() => _isSaving = true);
    try {
      final auth = context.read<AuthService>();
      final verificationSent = await auth.updateProfile(
        name: _nameController.text.trim(),
        profileImage: _profileImage,
      );
      final latestPhoto = auth.currentUser?.photoUrl;
      if (mounted) {
        setState(() {
          if (latestPhoto != null) {
            _initialPhotoUrl = latestPhoto;
            _profileImage = null;
            _imageBytes = null;
          }
          _isEditing = false; // Close edit mode after save
        });
      }
      if (verificationSent == true) {
        _showMessage(
            'A verification email was sent to the new address. Please verify to complete the change.');
      } else {
        _showMessage('Profile updated successfully.');
      }
    } catch (e) {
      _showMessage('Failed to update profile: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Logout',
          style: TextStyle(color: Colors.black), // Title in black
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(
                  color: Colors.black), // Also making Cancel button text black
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.black),
            child: const Text(
              'Logout',
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<AuthService>().signOut();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/role-selection');
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final user = auth.currentUser;
    final avatarImage = _resolveAvatar(user?.photoUrl);
    // Force refresh profile from Firestore if logged in and name is empty
    if (user != null && (user.name.isEmpty || user.name == '')) {
      Future.microtask(() => auth.refreshProfile());
    }

    return Scaffold(
      drawer: const AppDrawer(),
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFF7F9FD), Color(0xFFEFF3FA)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeaderCard(context, user, avatarImage),
                  const SizedBox(height: 16),
                  _buildFormCard(context),
                  const SizedBox(height: 16),
                  _buildActions(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(
      BuildContext context, AppUser? user, ImageProvider avatarImage) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1F477D), Color(0xFF2B66BD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 44,
            backgroundColor: Colors.white.withOpacity(0.18),
            backgroundImage: avatarImage,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? 'Your name',
                  style: textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  user?.email ?? '',
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  // ignore: prefer_const_constructors
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.verified_user_rounded,
                          size: 16, color: Colors.white),
                      SizedBox(width: 6),
                      Text(
                        'Secure account',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Profile Details',
                style: TextStyle(
                  color: AppColors.darkBlue,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              TextButton.icon(
                onPressed: _isSaving
                    ? null
                    : () {
                        setState(() {
                          // Prefill controllers with latest user info when entering edit mode
                          if (!_isEditing) {
                            final user =
                                context.read<AuthService>().currentUser;
                            if (user != null) {
                              _nameController.text = user.name;
                              _emailController.text = user.email;
                            }
                            _profileImage = null;
                            _imageBytes = null;
                          }
                          _isEditing = !_isEditing;
                        });
                      },
                icon: Icon(
                  _isEditing ? Icons.close : Icons.edit,
                  size: 18,
                ),
                label: Text(_isEditing ? 'Cancel' : 'Edit'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.darkBlue,
                ),
              ),
            ],
          ),
          if (_isEditing) ...[
            const SizedBox(height: 16),
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.paleBlue,
                      backgroundImage: _imageBytes != null
                          ? MemoryImage(_imageBytes!)
                          : (context
                                      .read<AuthService>()
                                      .currentUser
                                      ?.photoUrl
                                      ?.isNotEmpty ==
                                  true
                              ? NetworkImage(context
                                  .read<AuthService>()
                                  .currentUser!
                                  .photoUrl!)
                              : const AssetImage(
                                      'assets/images/logo/original/Logo_without_text_with_background.jpg')
                                  as ImageProvider),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.brightGold,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          color: AppColors.darkBlue,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _nameController,
              label: 'Full name',
              icon: Icons.person_outline,
              keyboardType: TextInputType.name,
            ),
            const SizedBox(height: 12),
            _buildReadOnlyField('Email',
                context.read<AuthService>().currentUser?.email ?? 'Not set'),
          ] else
            ...[],
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_isEditing)
          ElevatedButton(
            onPressed: _isSaving ? null : _saveProfile,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: AppColors.brightGold,
              foregroundColor: AppColors.darkBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: _isSaving
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.4),
                  )
                : const Text(
                    'Save Changes',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
          ),
        if (_isEditing) const SizedBox(height: 12),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _isSaving ? null : _confirmLogout,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.red, width: 2),
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            iconColor: Colors.red,
          ),
          icon: const Icon(Icons.logout_rounded, color: Colors.red),
          label: const Text('Logout', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: !_isSaving,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.darkBlue),
        filled: true,
        fillColor: AppColors.paleBlue,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      style: const TextStyle(color: AppColors.darkBlue),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.paleBlue,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const Icon(Icons.email_outlined,
                  color: AppColors.darkBlue, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.darkBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  ImageProvider _resolveAvatar(String? livePhotoUrl) {
    if (_imageBytes != null) return MemoryImage(_imageBytes!);
    if ((livePhotoUrl ?? _initialPhotoUrl)?.isNotEmpty == true) {
      return NetworkImage(livePhotoUrl ?? _initialPhotoUrl!);
    }
    return const AssetImage(
        'assets/images/logo/original/Logo_without_text_with_background.jpg');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
