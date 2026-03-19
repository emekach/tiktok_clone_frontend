// lib/screens/chat/chat_list_screen.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../utils/constants.dart';
import '../../providers/auth_provider.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      backgroundColor: AppConstants.obsidian,
      appBar: AppBar(
        title: const Text('Messages',
            style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 24,
                color: AppConstants.primaryGold)),
        actions: [
          IconButton(
              icon: const Icon(Icons.search, color: Colors.white70),
              onPressed: () {}),
          IconButton(
            onPressed: () => context.push('/profile/${user?.username ?? 'me'}'),
            icon: Hero(
              tag: 'profile_pic',
              child: CircleAvatar(
                radius: 15,
                backgroundColor: AppConstants.surfaceDark,
                backgroundImage: user?.avatarUrl != null
                    ? CachedNetworkImageProvider(user!.avatarUrl!,
                        headers: AppConstants.apiHeaders)
                    : null,
                child: user?.avatarUrl == null
                    ? const Icon(Icons.person, size: 20, color: Colors.white24)
                    : null,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView.builder(
        itemCount: 15,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (context, index) {
          return _ChatTile(index: index);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppConstants.primaryGold,
        child:
            const Icon(Icons.edit_note_rounded, color: Colors.black, size: 28),
      ),
    );
  }
}

class _ChatTile extends StatelessWidget {
  final int index;
  const _ChatTile({required this.index});

  @override
  Widget build(BuildContext context) {
    final isUnread = index == 0;
    return ListTile(
      onTap: () => context.push('/chat/detail/user_$index'),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: isUnread
              ? Border.all(color: AppConstants.primaryGold, width: 2)
              : null,
        ),
        child: CircleAvatar(
          radius: 28,
          backgroundColor: AppConstants.surfaceDark,
          backgroundImage: CachedNetworkImageProvider(
            'https://i.pravatar.cc/150?u=chat_$index',
            headers: AppConstants.apiHeaders,
          ),
        ),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Contact ${index + 1}',
            style: TextStyle(
                fontWeight: isUnread ? FontWeight.bold : FontWeight.w500,
                fontSize: 16,
                color: Colors.white),
          ),
          Text(
            '12:45 PM',
            style: TextStyle(
                color: isUnread ? AppConstants.primaryGold : Colors.white38,
                fontSize: 11),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Sent a message...',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: isUnread ? Colors.white70 : Colors.white38,
                    fontSize: 14),
              ),
            ),
            if (isUnread)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                    color: AppConstants.primaryGold, shape: BoxShape.circle),
              ),
          ],
        ),
      ),
    );
  }
}
