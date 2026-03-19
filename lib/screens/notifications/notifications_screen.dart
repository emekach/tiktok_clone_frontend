// lib/screens/notifications/notifications_screen.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _api = ApiService();
  List<dynamic> _notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await _api.getNotifications();
      if (mounted) {
        setState(() {
          _notifications = data['data'] ?? [];
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        surfaceTintColor: Colors.transparent,
        title: const Text('Inbox',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 17)),
        actions: [
          IconButton(
            icon: const Icon(Icons.send_rounded, color: Colors.white),
            onPressed: () =>
                context.push('/notifications/chat'), // Opens direct messages
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF0050)))
          : RefreshIndicator(
              onRefresh: _load,
              color: const Color(0xFFFF0050),
              backgroundColor: Colors.black,
              child: _notifications.isEmpty ? _buildEmptyState() : _buildList(),
            ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final n = _notifications[index];
        final actor = n['actor'] ?? {};
        final type = n['type'];
        final createdAt = n['created_at'];

        String message = '';
        IconData? icon;
        Color iconColor = Colors.white;

        switch (type) {
          case 'like':
            message = 'liked your video.';
            icon = Icons.favorite;
            iconColor = const Color(0xFFFF0050);
            break;
          case 'comment':
            message = 'commented on your video.';
            icon = Icons.comment;
            iconColor = Colors.blue;
            break;
          case 'follow':
            message = 'started following you.';
            icon = Icons.person_add;
            iconColor = const Color(0xFF00F2EA);
            break;
          default:
            message = 'interacted with you.';
        }

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey[900],
            backgroundImage: actor['avatar_url'] != null
                ? CachedNetworkImageProvider(actor['avatar_url'])
                : null,
            child: actor['avatar_url'] == null
                ? const Icon(Icons.person, color: Colors.white24)
                : null,
          ),
          title: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${actor['username'] ?? 'User'} ',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
                TextSpan(
                  text: message,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          subtitle: Text(
            _formatTime(createdAt),
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
          trailing: n['video'] != null
              ? Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: n['video']['thumbnail_url'] != null
                      ? CachedNetworkImage(
                          imageUrl: n['video']['thumbnail_url'],
                          fit: BoxFit.cover)
                      : const Icon(Icons.play_arrow,
                          color: Colors.white24, size: 20),
                )
              : type == 'follow'
                  ? OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFFF0050)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(2)),
                        minimumSize: const Size(60, 30),
                        padding: EdgeInsets.zero,
                      ),
                      child: const Text('Follow',
                          style: TextStyle(
                              color: Color(0xFFFF0050), fontSize: 12)),
                    )
                  : null,
          onTap: () {
            if (actor['username'] != null) {
              context.go('/profile/${actor['username']}');
            }
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        const Icon(Icons.notifications_none_outlined,
            size: 80, color: Colors.white12),
        const SizedBox(height: 24),
        const Text(
          'All activity',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 8),
        const Text(
          'Notifications about your account will appear here.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white38, fontSize: 14),
        ),
      ],
    );
  }

  String _formatTime(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final dt = DateTime.parse(dateStr);
      final diff = DateTime.now().difference(dt);
      if (diff.inDays > 0) return '${diff.inDays}d';
      if (diff.inHours > 0) return '${diff.inHours}h';
      if (diff.inMinutes > 0) return '${diff.inMinutes}m';
      return 'just now';
    } catch (_) {
      return '';
    }
  }
}
