// lib/utils/constants.dart
import 'package:flutter/material.dart';

class AppConstants {
  static const String baseUrl = 'https://test.ignisynclab.com/api';

  static const Map<String, String> apiHeaders = {
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
    'Referer': 'https://test.ignisynclab.com/',
  };

  // Luxe Design Palette
  static const Color primaryGold = Color(0xFFD4AF37); // Champagne Gold
  static const Color obsidian = Color(0xFF0A0A0B); // Deepest Black
  static const Color surfaceDark = Color(0xFF161618); // Elevated Surface
  static const Color glassWhite = Color(0x1AFFFFFF); // Glass layer
  static const Color accentRose = Color(0xFFFF4D6D); // Soft Rose accent

  static const String tokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String usernameKey = 'username';
}
