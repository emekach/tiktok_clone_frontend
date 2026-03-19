// lib/screens/profile/edit_profile_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _api = ApiService();
  final _nameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _webCtrl = TextEditingController();

  bool _loading = false;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      _nameCtrl.text = user.displayName;
      _bioCtrl.text = user.bio ?? '';
      _webCtrl.text = user.website ?? '';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    _webCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image != null) {
      setState(() => _imageFile = File(image.path));
    }
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    final auth = context.read<AuthProvider>();

    try {
      // 1. Update Avatar if changed
      if (_imageFile != null) {
        await _api.updateAvatar(_imageFile!.path);
      }

      // 2. Update Profile Info
      final res = await _api.updateProfile({
        'display_name': _nameCtrl.text.trim(),
        'bio': _bioCtrl.text.trim(),
        'website': _webCtrl.text.trim(),
      });

      // 3. Update local state
      auth.updateUser(UserModel.fromJson(res['user']));

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Update failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Edit profile',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        actions: [
          TextButton(
            onPressed: _loading ? null : _save,
            child: _loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Save',
                    style: TextStyle(
                        color: Color(0xFFFF0050),
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar Change
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[900],
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!)
                        : (user?.avatarUrl != null
                            ? CachedNetworkImageProvider(user!.avatarUrl!)
                            : null) as ImageProvider?,
                    child: (user?.avatarUrl == null && _imageFile == null)
                        ? const Icon(Icons.person,
                            size: 50, color: Colors.white24)
                        : null,
                  ),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt_outlined,
                        color: Colors.white, size: 30),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text('Change photo',
                style: TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 40),

            _buildField('Name', _nameCtrl, 'Enter your name'),
            _buildField('Bio', _bioCtrl, 'Add a bio to your profile',
                maxLines: 3),
            _buildField('Website', _webCtrl, 'Add your website'),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, String hint,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white54, fontSize: 14)),
          TextField(
            controller: ctrl,
            maxLines: maxLines,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white24),
              enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white12)),
              focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFFF0050))),
            ),
          ),
        ],
      ),
    );
  }
}
