// lib/screens/auth/register_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      username: _usernameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      displayName: _nameCtrl.text.trim(),
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (success) {
      context.go('/');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Registration failed'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Create your profile',
          style: TextStyle(
            color: Color(0xFF075E54),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF075E54)),
          onPressed: () => context.go('/auth/login'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 24),
                const Text(
                  'Please provide your details to finish setting up your account.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 32),

                // Avatar Placeholder (WhatsApp style)
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add_a_photo,
                      color: Colors.grey, size: 40),
                ),
                const SizedBox(height: 32),

                _buildField(_nameCtrl, 'Full Name', Icons.person_outline),
                const SizedBox(height: 16),
                _buildField(_usernameCtrl, 'Username', Icons.alternate_email),
                const SizedBox(height: 16),
                _buildField(_emailCtrl, 'Email Address', Icons.email_outlined,
                    keyboard: TextInputType.emailAddress),
                const SizedBox(height: 16),
                _buildField(_passwordCtrl, 'Password', Icons.lock_outline,
                    obscure: _obscure,
                    suffix: IconButton(
                      icon: Icon(
                          _obscure ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey,
                          size: 20),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    )),

                const SizedBox(height: 48),

                SizedBox(
                  width: 120,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text('FINISH',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType keyboard = TextInputType.text,
    bool obscure = false,
    Widget? suffix,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboard,
      obscureText: obscure,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF075E54)),
        prefixIcon: Icon(icon, color: const Color(0xFF075E54), size: 22),
        suffixIcon: suffix,
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF075E54), width: 1.5),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF075E54), width: 2),
        ),
      ),
      validator: (v) => v == null || v.isEmpty ? 'Required field' : null,
    );
  }
}
