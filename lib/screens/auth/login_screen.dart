// lib/screens/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final auth = context.read<AuthProvider>();
    final success =
        await auth.login(_emailCtrl.text.trim(), _passwordCtrl.text);

    if (!mounted) return;
    setState(() => _loading = false);

    if (success) {
      context.go('/');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Login failed'),
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
          'Enter your email',
          style: TextStyle(
            color: Color(0xFF075E54),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.grey),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 24),
                const Text(
                  'WhatsApp will need to verify your email address.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 32),

                // Email Field
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Color(0xFF075E54)),
                    enabledBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFF075E54), width: 1.5),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFF075E54), width: 2),
                    ),
                  ),
                  validator: (v) =>
                      v == null || !v.contains('@') ? 'Invalid email' : null,
                ),

                const SizedBox(height: 24),

                // Password Field
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: const TextStyle(color: Color(0xFF075E54)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFF075E54), width: 1.5),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFF075E54), width: 2),
                    ),
                  ),
                  validator: (v) =>
                      v == null || v.length < 6 ? 'Min 6 characters' : null,
                ),

                const Spacer(),

                const Text(
                  'Carrier SMS charges may apply',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 24),

                // Next Button
                SizedBox(
                  width: 90,
                  height: 40,
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
                                color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('NEXT',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),

                const SizedBox(height: 24),

                // Link to Register
                TextButton(
                  onPressed: () => context.go('/auth/register'),
                  child: const Text(
                    'Don\'t have an account? Sign up',
                    style: TextStyle(
                        color: Color(0xFF075E54), fontWeight: FontWeight.bold),
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
}
