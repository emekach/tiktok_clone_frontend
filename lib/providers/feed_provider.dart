// lib/providers/feed_provider.dart

import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class FeedProvider extends ChangeNotifier {
  final _api = ApiService();

  List<VideoModel> _videos   = [];
  bool _isLoading            = false;
  bool _hasMore              = true;
  int  _page                 = 1;
  String? _nextPage;
  String? _error;

  List<VideoModel> get videos    => _videos;
  bool             get isLoading => _isLoading;
  bool             get hasMore   => _hasMore;
  String?          get error     => _error;

  // ── For You Page ────────────────────────────────────────────────

  Future<void> loadFeed({bool refresh = false}) async {
    if (refresh) {
      _videos  = [];
      _page    = 1;
      _hasMore = true;
      _nextPage = null;
    }
    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    _error     = null;
    notifyListeners();

    try {
      final data = await _api.getFeed(page: _page);
      final newVideos = (data['data'] as List)
          .map((v) => VideoModel.fromJson(v))
          .toList();

      _videos.addAll(newVideos);
      _nextPage = data['next_page'];
      _hasMore  = _nextPage != null;
      _page++;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Optimistic like toggle ────────────────────────────────────────

  Future<void> toggleLike(int videoId) async {
    final idx = _videos.indexWhere((v) => v.id == videoId);
    if (idx == -1) return;

    final video = _videos[idx];
    // Optimistic update
    video.isLiked    = !video.isLiked;
    video.likesCount += video.isLiked ? 1 : -1;
    notifyListeners();

    try {
      await _api.toggleLike(videoId);
    } catch (_) {
      // Revert on failure
      video.isLiked    = !video.isLiked;
      video.likesCount += video.isLiked ? 1 : -1;
      notifyListeners();
    }
  }

  // ── Follow toggle ─────────────────────────────────────────────────

  void updateFollowStatus(int userId, bool isFollowing) {
    for (final video in _videos) {
      if (video.user.id == userId) {
        video.user.isFollowing = isFollowing;
      }
    }
    notifyListeners();
  }
}
