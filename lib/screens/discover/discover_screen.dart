// lib/screens/discover/discover_screen.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final _api = ApiService();
  final _searchCtrl = TextEditingController();
  List<UserModel> _users = [];
  List<HashtagModel> _hashtags = [];
  List<HashtagModel> _trending = [];
  bool _searching = false;
  bool _loadingTrending = true;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadTrending();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadTrending() async {
    try {
      final data = await _api.getTrending();
      if (mounted) {
        setState(() {
          _trending = (data['hashtags'] as List)
              .map((h) => HashtagModel.fromJson(h))
              .toList();
          _loadingTrending = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingTrending = false);
    }
  }

  Future<void> _search(String q) async {
    final cleanQuery = q.trim();
    if (cleanQuery.isEmpty) {
      setState(() {
        _users = [];
        _hashtags = [];
        _query = '';
        _searching = false;
      });
      return;
    }
    setState(() {
      _searching = true;
      _query = cleanQuery;
    });
    try {
      final data = await _api.search(cleanQuery);
      if (mounted) {
        setState(() {
          _users = (data['users'] as List)
              .map((u) => UserModel.fromJson(u))
              .toList();
          _hashtags = (data['hashtags'] as List)
              .map((h) => HashtagModel.fromJson(h))
              .toList();
          _searching = false;
        });
      }
    } catch (e) {
      debugPrint("Search Error: $e");
      if (mounted) setState(() => _searching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2E),
            borderRadius: BorderRadius.circular(4),
          ),
          child: TextField(
            controller: _searchCtrl,
            style: const TextStyle(color: Colors.white, fontSize: 15),
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              hintText: 'Search',
              hintStyle: const TextStyle(color: Colors.white38),
              border: InputBorder.none,
              prefixIcon:
                  const Icon(Icons.search, color: Colors.white70, size: 20),
              isDense: true,
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.cancel,
                          color: Colors.white38, size: 18),
                      onPressed: () {
                        _searchCtrl.clear();
                        _search('');
                      },
                    )
                  : null,
            ),
            onChanged: (v) => _search(v),
            onSubmitted: _search,
          ),
        ),
      ),
      body: _query.isEmpty ? _buildTrending() : _buildResults(),
    );
  }

  Widget _buildTrending() {
    if (_loadingTrending) {
      return _buildTrendingShimmer();
    }
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text('Trending Hashtags',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
        ),
        ..._trending.map((h) => ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.tag, color: Colors.white, size: 20),
              ),
              title: Text(h.name,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
              subtitle: Text('${_formatCount(h.videosCount)} videos',
                  style: const TextStyle(color: Colors.white38, fontSize: 12)),
              onTap: () {},
            )),
      ],
    );
  }

  Widget _buildResults() {
    if (_searching) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFFFF0050)));
    }
    if (_users.isEmpty && _hashtags.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, color: Colors.white24, size: 64),
            const SizedBox(height: 16),
            Text('No results for "$_query"',
                style: const TextStyle(color: Colors.white38)),
          ],
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        if (_users.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('Users',
                style: TextStyle(
                    color: Colors.white38,
                    fontSize: 13,
                    fontWeight: FontWeight.bold)),
          ),
          ..._users.map((u) => ListTile(
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.grey[900],
                  backgroundImage: u.avatarUrl != null
                      ? CachedNetworkImageProvider(u.avatarUrl!)
                      : null,
                  child: u.avatarUrl == null
                      ? const Icon(Icons.person, color: Colors.white24)
                      : null,
                ),
                title: Text(u.username,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600)),
                subtitle: Text(u.displayName,
                    style: const TextStyle(color: Colors.white38)),
                trailing: ElevatedButton(
                  onPressed: () => context.go('/profile/${u.username}'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF0050),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(80, 32),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2)),
                    elevation: 0,
                  ),
                  child: const Text('View',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                ),
                onTap: () => context.go('/profile/${u.username}'),
              )),
        ],
        if (_hashtags.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
            child: Text('Hashtags',
                style: TextStyle(
                    color: Colors.white38,
                    fontSize: 13,
                    fontWeight: FontWeight.bold)),
          ),
          ..._hashtags.map((h) => ListTile(
                leading: const Icon(Icons.tag, color: Colors.white38),
                title: Text(h.name,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600)),
                subtitle: Text('${_formatCount(h.videosCount)} videos',
                    style: const TextStyle(color: Colors.white38)),
                onTap: () {},
              )),
        ],
      ],
    );
  }

  Widget _buildTrendingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[900]!,
      highlightColor: Colors.grey[800]!,
      child: ListView.builder(
        itemCount: 10,
        itemBuilder: (_, __) => ListTile(
          leading: const CircleAvatar(backgroundColor: Colors.white),
          title: Container(height: 12, color: Colors.white),
          subtitle: Container(
              height: 10,
              color: Colors.white,
              margin: const EdgeInsets.only(top: 4),
              width: 100),
        ),
      ),
    );
  }

  String _formatCount(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}
