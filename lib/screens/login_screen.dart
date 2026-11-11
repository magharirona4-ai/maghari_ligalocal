
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../auth_state.dart';
import '../auth_widgets.dart';
import '../theme.dart';
import '../widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _remember = true;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_email.text.trim().isEmpty || _password.text.isEmpty) {
      setState(() => _error = 'Enter your email and password.');
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    final err = await auth.login(_email.text, _password.text);

    if (!mounted) return;

    setState(() {
      _busy = false;
      _error = err;
    });

    // On success, the router moves you to Home.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 22,
            vertical: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Column(
                  children: [
                    LogoMark(size: 72),
                    SizedBox(height: 6),
                    Text(
                      'LigaLocal',
                      style: TextStyle(
                        color: C.navy,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Barangay Sports Festival\nScheduling & Live Standing Board',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: C.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                'Welcome Back!',
                style: TextStyle(
                  color: C.navy,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 14),

              AuthField(
                controller: _email,
                light: true,
                hint: 'Email Address',
                icon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 12),

              AuthField(
                controller: _password,
                light: true,
                hint: 'Password',
                icon: Icons.lock_outline,
                password: true,
              ),

              const SizedBox(height: 4),

              Row(
                children: [
                  Checkbox(
                    value: _remember,
                    activeColor: C.navy,
                    visualDensity: VisualDensity.compact,
                    onChanged: (v) {
                      setState(() => _remember = v ?? false);
                    },
                  ),

                  const Text(
                    'Remember me',
                    style: TextStyle(
                      color: C.navy,
                      fontSize: 12,
                    ),
                  ),

                  const Spacer(),

                  TextButton(
                    onPressed: () => context.go('/forgot-password'),
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: C.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    _error!,
                    style: const TextStyle(
                      color: C.red,
                      fontSize: 12,
                    ),
                  ),
                ),

              const SizedBox(height: 4),

              PrimaryButton(
                _busy ? 'Please wait...' : 'Log In',
                onPressed: _busy ? () {} : _submit,
              ),

              const SizedBox(height: 16),

              Center(
                child: TextButton(
                  onPressed: () => context.go('/register'),
                  child: const Text(
                    "Don't have an account? Sign Up",
                    style: TextStyle(
                      color: C.navy,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
