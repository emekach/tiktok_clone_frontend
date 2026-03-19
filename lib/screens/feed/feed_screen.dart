// lib/screens/feed/feed_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/feed_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import 'video_player_item.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 1);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FeedProvider>().loadFeed();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // WhatsApp light background
      appBar: AppBar(
        title: const Text('Status',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Consumer<FeedProvider>(
        builder: (context, feed, _) {
          if (feed.isLoading && feed.videos.isEmpty) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF075E54)));
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMyStatus(),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text('Recent updates',
                    style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: feed.videos.length,
                  itemBuilder: (context, index) {
                    final video = feed.videos[index];
                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: const Color(0xFF25D366), width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 26,
                          backgroundImage: video.user.avatarUrl != null
                              ? CachedNetworkImageProvider(
                                  video.user.avatarUrl!,
                                  headers: AppConstants.apiHeaders)
                              : null,
                          child: video.user.avatarUrl == null
                              ? const Icon(Icons.person)
                              : null,
                        ),
                      ),
                      title: Text(video.user.username,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Today, ${10 + index}:00 AM'),
                      onTap: () => _showFullVideo(video),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMyStatus() {
    final user = context.read<AuthProvider>().currentUser;
    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.grey[200],
            backgroundImage: user?.avatarUrl != null
                ? CachedNetworkImageProvider(user!.avatarUrl!,
                    headers: AppConstants.apiHeaders)
                : null,
            child: user?.avatarUrl == null
                ? const Icon(Icons.person, size: 30, color: Colors.white)
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                  color: Color(0xFF25D366), shape: BoxShape.circle),
              child: const Icon(Icons.add, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
      title: const Text('My Status',
          style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: const Text('Tap to add status update'),
      onTap: () => context.go('/upload'),
    );
  }

  void _showFullVideo(video) {
    // Show vertical video overlay (Status view)
    showDialog(
      context: context,
      useSafeArea: false,
      builder: (context) => Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            VideoPlayerItem(
              video: video,
              isActive: true,
              shouldLoad: true,
              onLike: () {},
            ),
            Positioned(
              top: 40,
              left: 10,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
