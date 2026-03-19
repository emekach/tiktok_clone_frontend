// lib/providers/auth_provider.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final _api     = ApiService();
  final _storage = const FlutterSecureStorage();

  AuthStatus _status = AuthStatus.unknown;
  UserModel? _currentUser;
  String?   _error;

  AuthStatus get status      => _status;
  UserModel? get currentUser => _currentUser;
  String?    get error       => _error;
  bool       get isLoggedIn  => _status == AuthStatus.authenticated;

  // ── Bootstrap ────────────────────────────────────────────────────

  Future<void> checkAuth() async {
    final token = await _storage.read(key: AppConstants.tokenKey);
    if (token == null) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }
    try {
      final data = await _api.getMe();
      _currentUser = UserModel.fromJson(data['user']);
      _status = AuthStatus.authenticated;
    } catch (_) {
      await _clearStorage();
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  // ── Register ─────────────────────────────────────────────────────

  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String displayName,
  }) async {
    _error = null;
    try {
      final data = await _api.register({
        'username':              username,
        'email':                 email,
        'password':              password,
        'password_confirmation': password,
        'display_name':          displayName,
      });
      await _saveSession(data);
      return true;
    } catch (e) {
      _error = _parseError(e);
      notifyListeners();
      return false;
    }
  }

  // ── Login ─────────────────────────────────────────────────────────

  Future<bool> login(String email, String password) async {
    _error = null;
    try {
      final data = await _api.login(email, password);
      await _saveSession(data);
      return true;
    } catch (e) {
      _error = _parseError(e);
      notifyListeners();
      return false;
    }
  }

  // ── Logout ────────────────────────────────────────────────────────

  Future<void> logout() async {
    try {
      await _api.logout();
    } catch (_) {}
    await _clearStorage();
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  // ── Update local user ─────────────────────────────────────────────

  void updateUser(UserModel user) {
    _currentUser = user;
    notifyListeners();
  }

  // ── Helpers ───────────────────────────────────────────────────────

  Future<void> _saveSession(Map<String, dynamic> data) async {
    final token = data['token'] as String;
    await _storage.write(key: AppConstants.tokenKey, value: token);
    _currentUser = UserModel.fromJson(data['user']);
    _status = AuthStatus.authenticated;
    notifyListeners();
  }

  Future<void> _clearStorage() async {
    await _storage.delete(key: AppConstants.tokenKey);
  }

  String _parseError(dynamic e) {
    if (e.toString().contains('422') || e.toString().contains('validation')) {
      return 'Please check your input and try again.';
    }
    if (e.toString().contains('401')) return 'Invalid email or password.';
    if (e.toString().contains('SocketException')) return 'No internet connection.';
    return 'Something went wrong. Please try again.';
  }
}
