import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../auth_state.dart';
import '../auth_widgets.dart';
import '../theme.dart';
import '../widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_email.text.trim().isEmpty) {
      setState(() => _error = 'Enter your email address.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final err = await auth.sendPasswordReset(_email.text);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = err;
    });
    if (err == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reset link sent! Check your email.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: navyAppBar(context, 'Forgot Password', fallback: '/login'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 50),
        child: Column(children: [
          const LogoMark(size: 56),
          const SizedBox(height: 16),
          const Text('Reset Your Password',
              style: TextStyle(color: C.navy, fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          const Text('Enter your email and we will send\nyou a password reset link.',
              textAlign: TextAlign.center,
              style: TextStyle(color: C.grey, fontSize: 12)),
          const SizedBox(height: 24),
          AuthField(
              controller: _email,
              light: true,
              hint: 'Email Address',
              icon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(_error!, style: const TextStyle(color: C.red, fontSize: 12)),
            ),
          const SizedBox(height: 12),
          PrimaryButton(_busy ? 'Please wait...' : 'Send Reset Link',
              onPressed: _busy ? () {} : _send),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => context.go('/login'),
            child: const Text('Back to Log In',
                style: TextStyle(
                    color: C.orange, fontSize: 12, fontWeight: FontWeight.w700)),
          ),
        ]),
      ),
    );
  }
}
