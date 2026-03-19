// lib/screens/auth/otp_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/constants.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  bool _loading = false;

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _verify() async {
    setState(() => _loading = true);
    // Simulate verification
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      context.go('/auth/register');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.obsidian,
      appBar: AppBar(
        title: const Text('Verify Email',
            style: TextStyle(fontSize: 18, color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 20, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Icon(Icons.mark_email_read_outlined,
                size: 80, color: AppConstants.primaryGold),
            const SizedBox(height: 32),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(color: Colors.white70, fontSize: 15),
                children: [
                  const TextSpan(text: 'We sent a verification code to\n'),
                  TextSpan(
                      text: widget.email,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) => _buildOtpField(index)),
            ),
            const SizedBox(height: 40),
            if (_loading)
              const CircularProgressIndicator(color: AppConstants.primaryGold)
            else
              TextButton(
                onPressed: () {},
                child: const Text('Resend Code',
                    style: TextStyle(
                        color: AppConstants.primaryGold,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1)),
              ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildOtpField(int index) {
    return SizedBox(
      width: 45,
      child: TextField(
        controller: _controllers[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(
            fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        decoration: InputDecoration(
          counterText: '',
          enabledBorder: UnderlineInputBorder(
              borderSide:
                  BorderSide(color: Colors.white.withOpacity(0.1), width: 2)),
          focusedBorder: const UnderlineInputBorder(
              borderSide:
                  BorderSide(color: AppConstants.primaryGold, width: 2)),
        ),
        onChanged: (v) {
          if (v.isNotEmpty && index < 5) {
            FocusScope.of(context).nextFocus();
          }
          if (_controllers.every((c) => c.text.isNotEmpty)) {
            _verify();
          }
        },
      ),
    );
  }
}
