import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../widgets/app_drawer.dart';

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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        toolbarHeight: 44,
        automaticallyImplyLeading: false,
        title: Builder(
          builder: (ctx) => Row(
            children: [
              IconButton(
                icon: const Icon(Icons.menu, color: Color(0xFF1F477D)),
                onPressed: () {
                  Scaffold.of(ctx).openDrawer();
                },
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 28,
                child: Image.asset(
                  'assets/images/logo/original/Text_without_logo_without_background.png',
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1F477D)),
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
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
                                        'assets/images/logo/original/Logo_without_text_with_background.jpg'))
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
