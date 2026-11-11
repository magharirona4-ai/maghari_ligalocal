import 'dart:async';
import 'package:flutter/material.dart';
import '../auth_state.dart';
import '../theme.dart';
import '../widgets.dart';

/// Only shown when requireEmailVerification = true in auth_state.dart
class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  int _left = 58;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _left = 58);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        if (_left > 0) _left--;
      });
      if (_left == 0) t.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toast(String text) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(text)));

  Future<void> _check() async {
    final err = await auth.checkEmailVerified();
    if (!mounted) return;
    if (err != null) _toast(err);
    // On success the router moves you to Home by itself.
  }

  Future<void> _resend() async {
    await auth.resendVerification();
    if (!mounted) return;
    _startTimer();
    _toast('Verification email sent.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(children: [
              const LogoMark(size: 90),
              const SizedBox(height: 24),
              const Icon(Icons.check, color: C.green, size: 48),
              const SizedBox(height: 16),
              const Text('Verify Your Email',
                  style: TextStyle(
                      color: C.navy, fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              const Text(
                "We've sent a verification link to\nyour email address.\n"
                'Please check your inbox and follow\nthe instructions to continue.',
                textAlign: TextAlign.center,
                style: TextStyle(color: C.navy, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 20),
              // Open the link in your email first, then tap this button.
              PrimaryButton('Open Email App', onPressed: _check),
              const SizedBox(height: 8),
              const Text('After opening the link, tap the button above.',
                  style: TextStyle(color: C.grey, fontSize: 11)),
              const SizedBox(height: 12),
              _left > 0
                  ? Text(
                      'Resend Code in\n00:${_left.toString().padLeft(2, '0')}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: C.grey, fontSize: 15),
                    )
                  : TextButton(
                      onPressed: _resend,
                      child: const Text('Resend Code',
                          style: TextStyle(
                              color: C.orange, fontWeight: FontWeight.w700)),
                    ),
            ]),
          ),
        ),
      ),
    );
  }
}
