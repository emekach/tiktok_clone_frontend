// lib/screens/profile/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';

class ProfileScreen extends StatelessWidget {
  final String username;
  const ProfileScreen({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    if (user == null)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text('Settings',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ],
      ),
      body: ListView(
        children: [
          // User Profile Header
          Container(
            color: Colors.white,
            child: ListTile(
              onTap: () => context.push('/profile/${user.username}/edit'),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              leading: Hero(
                tag: 'profile_pic',
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: user.avatarUrl != null
                      ? CachedNetworkImageProvider(user.avatarUrl!,
                          headers: AppConstants.apiHeaders)
                      : null,
                  child: user.avatarUrl == null
                      ? const Icon(Icons.person, size: 35, color: Colors.white)
                      : null,
                ),
              ),
              title: Text(user.displayName,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w500)),
              subtitle: Text(user.bio ?? 'Hey there! I am using WhatsApp.',
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              trailing: const Icon(Icons.qr_code, color: Color(0xFF075E54)),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE0E0E0)),

          _buildSettingsTile(
              Icons.key, 'Account', 'Security notifications, change number'),
          _buildSettingsTile(Icons.lock_outline, 'Privacy',
              'Block contacts, disappearing messages'),
          _buildSettingsTile(
              Icons.face_outlined, 'Avatar', 'Create, edit, profile photo'),
          _buildSettingsTile(
              Icons.chat_outlined, 'Chats', 'Theme, wallpapers, chat history'),
          _buildSettingsTile(Icons.notifications_none, 'Notifications',
              'Message, group & call tones'),
          _buildSettingsTile(Icons.data_usage, 'Storage and data',
              'Network usage, auto-download'),
          _buildSettingsTile(
              Icons.language, 'App language', 'English (phone\'s language)'),
          _buildSettingsTile(Icons.help_outline, 'Help',
              'Help center, contact us, privacy policy'),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                Text('from',
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text('META',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        fontSize: 14)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, String subtitle) {
    return Container(
      color: Colors.white,
      child: ListTile(
        leading: Icon(icon, color: Colors.grey[600]),
        title: Text(title, style: const TextStyle(fontSize: 16)),
        subtitle: Text(subtitle,
            style: const TextStyle(fontSize: 13, color: Colors.grey)),
        onTap: () {},
      ),
    );
  }
}
