// lib/screens/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            // Welcome Image / Logo
            Image.network(
              'https://static.whatsapp.net/rsrc.php/v3/yP/r/r_v97_Spx9U.png',
              height: 280,
              width: 280,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.chat_bubble_outline,
                size: 150,
                color: Color(0xFF25D366),
              ),
            ),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Welcome to WhatsApp',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                  children: [
                    TextSpan(text: 'Read our '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(color: Color(0xFF007AFF)),
                    ),
                    TextSpan(text: '. Tap "Agree and continue" to accept the '),
                    TextSpan(
                      text: 'Terms of Service',
                      style: TextStyle(color: Color(0xFF007AFF)),
                    ),
                    TextSpan(text: '.'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Agree and Continue Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => context.go('/auth/login'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'AGREE AND CONTINUE',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 48),
            const Text(
              'from',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const Text(
              'META',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                fontSize: 14,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
