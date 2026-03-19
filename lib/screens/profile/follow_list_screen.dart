// lib/screens/profile/follow_list_screen.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';

class FollowListScreen extends StatefulWidget {
  final int userId;
  final String username;
  final String type; // 'followers' or 'following'

  const FollowListScreen({
    super.key,
    required this.userId,
    required this.username,
    required this.type,
  });

  @override
  State<FollowListScreen> createState() => _FollowListScreenState();
}

class _FollowListScreenState extends State<FollowListScreen> {
  final _api = ApiService();
  List<UserModel> _users = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = widget.type == 'followers'
          ? await _api.getFollowers(widget.userId)
          : await _api.getFollowing(widget.userId);

      if (mounted) {
        setState(() {
          _users =
              (res['data'] as List).map((u) => UserModel.fromJson(u)).toList();
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
        title: Text(widget.username,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Column(
            children: [
              Text(
                widget.type == 'followers' ? 'Followers' : 'Following',
                style: const TextStyle(
                    color: Color(0xFFFF0050), fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Divider(color: Colors.white12, height: 1),
            ],
          ),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF0050)))
          : _users.isEmpty
              ? _buildEmpty()
              : ListView.builder(
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    final user = _users[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: user.avatarUrl != null
                            ? CachedNetworkImageProvider(user.avatarUrl!)
                            : null,
                        child: user.avatarUrl == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: Text(user.username,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      subtitle: Text(user.displayName,
                          style: const TextStyle(color: Colors.white38)),
                      trailing: OutlinedButton(
                        onPressed: () =>
                            context.go('/profile/${user.username}'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white24),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(2)),
                        ),
                        child: const Text('View',
                            style: TextStyle(color: Colors.white)),
                      ),
                      onTap: () => context.go('/profile/${user.username}'),
                    );
                  },
                ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
              widget.type == 'followers'
                  ? Icons.person_add_outlined
                  : Icons.person_outline,
              size: 80,
              color: Colors.white12),
          const SizedBox(height: 16),
          Text(
            widget.type == 'followers'
                ? 'No followers yet'
                : 'Not following anyone',
            style: const TextStyle(color: Colors.white38, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
