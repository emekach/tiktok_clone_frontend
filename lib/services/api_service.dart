// lib/services/api_service.dart

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final _storage = const FlutterSecureStorage();
  late final Dio _dio;

  void init() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: AppConstants.tokenKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException error, handler) {
        return handler.next(error);
      },
    ));
  }

  // ── Auth ─────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    final res = await _dio.post('/auth/register', data: data);
    return res.data;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return res.data;
  }

  Future<void> logout() async {
    await _dio.post('/auth/logout');
  }

  Future<Map<String, dynamic>> getMe() async {
    final res = await _dio.get('/auth/me');
    return res.data;
  }

  Future<void> updateFcmToken(String token) async {
    await _dio.post('/auth/fcm-token', data: {'fcm_token': token});
  }

  // ── Feed ─────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getFeed({int page = 1}) async {
    // Adding headers to feed as well to ensure video metadata/thumbs load
    final res = await _dio.get('/feed',
        queryParameters: {'page': page},
        options: Options(headers: AppConstants.apiHeaders));
    return res.data;
  }

  Future<Map<String, dynamic>> getFollowingFeed({int page = 1}) async {
    final res = await _dio.get('/feed/following',
        queryParameters: {'page': page},
        options: Options(headers: AppConstants.apiHeaders));
    return res.data;
  }

  // ── Videos ───────────────────────────────────────────────────────

  Future<Map<String, dynamic>> uploadVideo({
    required String filePath,
    String? description,
    String? musicName,
    int duration = 0,
    void Function(int, int)? onProgress,
  }) async {
    final formData = FormData.fromMap({
      'video': await MultipartFile.fromFile(
        filePath,
        filename: filePath.split('/').last,
      ),
      if (description != null) 'description': description,
      if (musicName != null) 'music_name': musicName,
      'duration': duration,
    });

    final res = await _dio.post(
      '/videos',
      data: formData,
      onSendProgress: onProgress,
      options: Options(
        sendTimeout: const Duration(minutes: 10),
        receiveTimeout: const Duration(minutes: 10),
        headers: AppConstants.apiHeaders,
      ),
    );
    return res.data;
  }

  Future<Map<String, dynamic>> getVideo(int videoId) async {
    final res = await _dio.get('/videos/$videoId',
        options: Options(headers: AppConstants.apiHeaders));
    return res.data;
  }

  Future<void> deleteVideo(int videoId) async {
    await _dio.delete('/videos/$videoId');
  }

  Future<Map<String, dynamic>> getUserVideos(int userId, {int page = 1}) async {
    final res = await _dio.get('/videos/user/$userId',
        queryParameters: {'page': page},
        options: Options(headers: AppConstants.apiHeaders));
    return res.data;
  }

  Future<Map<String, dynamic>> getVideosByHashtag(String tag,
      {int page = 1}) async {
    final res = await _dio.get('/videos/hashtag/$tag',
        queryParameters: {'page': page},
        options: Options(headers: AppConstants.apiHeaders));
    return res.data;
  }

  // ── Social ───────────────────────────────────────────────────────

  Future<Map<String, dynamic>> toggleLike(int videoId) async {
    final res = await _dio.post('/videos/$videoId/like');
    return res.data;
  }

  Future<Map<String, dynamic>> getComments(int videoId, {int page = 1}) async {
    final res = await _dio.get('/videos/$videoId/comments',
        queryParameters: {'page': page},
        options: Options(headers: AppConstants.apiHeaders));
    return res.data;
  }

  Future<Map<String, dynamic>> addComment(int videoId, String content,
      {int? parentId}) async {
    final res = await _dio.post('/videos/$videoId/comments', data: {
      'content': content,
      if (parentId != null) 'parent_id': parentId,
    });
    return res.data;
  }

  Future<void> deleteComment(int commentId) async {
    await _dio.delete('/comments/$commentId');
  }

  Future<Map<String, dynamic>> toggleFollow(int userId) async {
    final res = await _dio.post('/users/$userId/follow');
    return res.data;
  }

  Future<Map<String, dynamic>> getFollowers(int userId) async {
    final res = await _dio.get('/users/$userId/followers',
        options: Options(headers: AppConstants.apiHeaders));
    return res.data;
  }

  Future<Map<String, dynamic>> getFollowing(int userId) async {
    final res = await _dio.get('/users/$userId/following',
        options: Options(headers: AppConstants.apiHeaders));
    return res.data;
  }

  // ── Profile ──────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getProfile(String username) async {
    final res = await _dio.get('/profile/$username',
        options: Options(headers: AppConstants.apiHeaders));
    return res.data;
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final res = await _dio.put('/profile', data: data);
    return res.data;
  }

  Future<Map<String, dynamic>> updateAvatar(String filePath) async {
    final formData = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(filePath, filename: 'avatar.jpg'),
    });
    final res = await _dio.post('/profile/avatar',
        data: formData, options: Options(headers: AppConstants.apiHeaders));
    return res.data;
  }

  // ── Search & Discover ────────────────────────────────────────────

  Future<Map<String, dynamic>> search(String query) async {
    // CRITICAL: Headers added here to bypass 403
    final res = await _dio.get(
      '/search',
      queryParameters: {'q': query},
      options: Options(headers: AppConstants.apiHeaders),
    );
    return res.data;
  }

  Future<Map<String, dynamic>> getTrending() async {
    final res = await _dio.get('/trending',
        options: Options(headers: AppConstants.apiHeaders));
    return res.data;
  }

  // ── Notifications ────────────────────────────────────────────────

  Future<Map<String, dynamic>> getNotifications() async {
    final res = await _dio.get('/notifications',
        options: Options(headers: AppConstants.apiHeaders));
    return res.data;
  }

  Future<Map<String, dynamic>> getUnreadCount() async {
    final res = await _dio.get('/notifications/unread',
        options: Options(headers: AppConstants.apiHeaders));
    return res.data;
  }
}
