import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  File? _profileImage;
  String? _initialPhotoUrl;
  bool _isSaving = false;

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
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty) {
      _showMessage('Name and email cannot be empty.');
      return;
    }

    setState(() => _isSaving = true);
    try {
      final auth = context.read<AuthService>();
      final verificationSent = await auth.updateProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        profileImage: _profileImage,
      );
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

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    const darkBlue = Color(0xFF1F477D);
    const brightGold = Color(0xFFF0B84D);

    return SafeArea(
      child: Column(
        children: [
          // Reduced height, white background header (logo and logout only)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  height: 32,
                  child: Image.asset(
                    'images/logo/original/Text_without_logo_without_background.png',
                    fit: BoxFit.contain,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.red),
                  tooltip: 'Logout',
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Logout'),
                        content: const Text('Are you sure you want to logout?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: TextButton.styleFrom(
                                foregroundColor: Colors.red),
                            child: const Text('Logout'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true && context.mounted) {
                      await context.read<AuthService>().signOut();
                      if (context.mounted) {
                        Navigator.pushReplacementNamed(context, '/user-login');
                      }
                    }
                  },
                ),
              ],
            ),
          ),
          // Heading below the header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Edit Profile',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: darkBlue,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 48,
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : (_initialPhotoUrl != null
                                    ? NetworkImage(_initialPhotoUrl!)
                                    : const AssetImage(
                                        'images/default_avatar.png'))
                                as ImageProvider,
                        child: _profileImage == null
                            ? const Icon(Icons.camera_alt,
                                size: 32, color: Colors.white)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                      style: const TextStyle(color: darkBlue),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      style: const TextStyle(color: darkBlue),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: brightGold,
                          foregroundColor: darkBlue,
                        ),
                        child: _isSaving
                            ? const CircularProgressIndicator()
                            : const Text('Save Changes'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
