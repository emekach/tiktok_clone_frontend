// lib/models/models.dart

class UserModel {
  final int id;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final String? bio;
  final String? website;
  final int followersCount;
  final int followingCount;
  final int likesCount;
  final bool isVerified;
  final bool isPrivate;
  bool isFollowing;
  final bool isMe;

  UserModel({
    required this.id,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    this.bio,
    this.website,
    this.followersCount = 0,
    this.followingCount = 0,
    this.likesCount = 0,
    this.isVerified = false,
    this.isPrivate = false,
    this.isFollowing = false,
    this.isMe = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: _toInt(json['id']),
        username: json['username'] ?? '',
        displayName: json['display_name'] ?? json['username'] ?? '',
        avatarUrl: _fixUrl(json['avatar_url']),
        bio: json['bio'],
        website: json['website'],
        followersCount: _toInt(json['followers_count']),
        followingCount: _toInt(json['following_count']),
        likesCount: _toInt(json['likes_count']),
        isVerified: _toBool(json['is_verified']),
        isPrivate: _toBool(json['is_private']),
        isFollowing: _toBool(json['is_following']),
        isMe: _toBool(json['is_me']),
      );
}

// ── VideoModel ────────────────────────────────────────────────────────────

class VideoModel {
  final int id;
  final String? description;
  final String videoUrl;
  final String? thumbnailUrl;
  final int duration;
  final int viewsCount;
  int likesCount;
  final int commentsCount;
  final int sharesCount;
  final String? musicName;
  final String? musicArtist;
  final bool allowComments;
  bool isLiked;
  final List<String> hashtags;
  final DateTime createdAt;
  final VideoUserModel user;

  VideoModel({
    required this.id,
    this.description,
    required this.videoUrl,
    this.thumbnailUrl,
    required this.duration,
    this.viewsCount = 0,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.sharesCount = 0,
    this.musicName,
    this.musicArtist,
    this.allowComments = true,
    this.isLiked = false,
    this.hashtags = const [],
    required this.createdAt,
    required this.user,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) => VideoModel(
        id: _toInt(json['id']),
        description: json['description'],
        videoUrl: _fixUrl(json['video_url']) ?? '',
        thumbnailUrl: _fixUrl(json['thumbnail_url']),
        duration: _toInt(json['duration']),
        viewsCount: _toInt(json['views_count']),
        likesCount: _toInt(json['likes_count']),
        commentsCount: _toInt(json['comments_count']),
        sharesCount: _toInt(json['shares_count']),
        musicName: json['music_name'],
        musicArtist: json['music_artist'],
        allowComments: _toBool(json['allow_comments'], defaultValue: true),
        isLiked: _toBool(json['is_liked']),
        hashtags: List<String>.from(json['hashtags'] ?? []),
        createdAt:
            DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
        user: VideoUserModel.fromJson(json['user'] ?? {}),
      );
}

class VideoUserModel {
  final int id;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final bool isVerified;
  bool isFollowing;

  VideoUserModel({
    required this.id,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    this.isVerified = false,
    this.isFollowing = false,
  });

  factory VideoUserModel.fromJson(Map<String, dynamic> json) => VideoUserModel(
        id: _toInt(json['id']),
        username: json['username'] ?? '',
        displayName: json['display_name'] ?? json['username'] ?? '',
        avatarUrl: _fixUrl(json['avatar_url']),
        isVerified: _toBool(json['is_verified']),
        isFollowing: _toBool(json['is_following']),
      );
}

// ── CommentModel ──────────────────────────────────────────────────────────

class CommentModel {
  final int id;
  final String content;
  final int likesCount;
  final DateTime createdAt;
  final List<CommentModel> replies;
  final CommentUserModel user;

  CommentModel({
    required this.id,
    required this.content,
    this.likesCount = 0,
    required this.createdAt,
    this.replies = const [],
    required this.user,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) => CommentModel(
        id: _toInt(json['id']),
        content: json['content'] ?? '',
        likesCount: _toInt(json['likes_count']),
        createdAt:
            DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
        replies: (json['replies'] as List? ?? [])
            .map((r) => CommentModel.fromJson(r))
            .toList(),
        user: CommentUserModel.fromJson(json['user'] ?? {}),
      );
}

class CommentUserModel {
  final int id;
  final String username;
  final String displayName;
  final String? avatarUrl;

  CommentUserModel({
    required this.id,
    required this.username,
    required this.displayName,
    this.avatarUrl,
  });

  factory CommentUserModel.fromJson(Map<String, dynamic> json) =>
      CommentUserModel(
        id: _toInt(json['id']),
        username: json['username'] ?? '',
        displayName: json['display_name'] ?? json['username'] ?? '',
        avatarUrl: _fixUrl(json['avatar_url']),
      );
}

// ── HashtagModel ──────────────────────────────────────────────────────────

class HashtagModel {
  final int id;
  final String name;
  final int videosCount;

  HashtagModel({required this.id, required this.name, this.videosCount = 0});

  factory HashtagModel.fromJson(Map<String, dynamic> json) => HashtagModel(
        id: _toInt(json['id']),
        name: json['name'] ?? '',
        videosCount: _toInt(json['videos_count']),
      );
}

// ── Parsing Helpers ───────────────────────────────────────────────────────

int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

bool _toBool(dynamic value, {bool defaultValue = false}) {
  if (value == null) return defaultValue;
  if (value is bool) return value;
  if (value is int) return value == 1;
  if (value is String) {
    final v = value.toLowerCase();
    return v == 'true' || v == '1' || v == 'yes';
  }
  return defaultValue;
}

String? _fixUrl(dynamic url) {
  if (url == null || url.toString().isEmpty) return null;
  final String s = url.toString();
  if (s.startsWith('http')) return s;
  // Prepend the storage path for Laravel relative URLs
  return 'https://test.ignisynclab.com/storage/$s';
}
