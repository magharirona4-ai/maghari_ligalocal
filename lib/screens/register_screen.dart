import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../auth_state.dart';
import '../auth_widgets.dart';
import '../theme.dart';
import '../widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  int _role = 0; // 0 = Player, 1 = Organizer
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_name.text.trim().isEmpty ||
        _email.text.trim().isEmpty ||
        _username.text.trim().isEmpty ||
        _password.text.isEmpty) {
      setState(() => _error = 'Please fill in all fields.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final err = await auth.signUp(
      fullName: _name.text,
      email: _email.text,
      username: _username.text,
      password: _password.text,
      role: _role == 1 ? 'organizer' : 'player',
    );
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = err;
    });
    // On success the router moves you to Home by itself.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: navyAppBar(context, 'Create Account', fallback: '/login'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Create Account',
              style: TextStyle(color: C.navy, fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text('Join LigaLocal and be part\nof the barangay sports community.',
              style: TextStyle(color: C.navy, fontSize: 11)),
          const SizedBox(height: 32),
          AuthField(controller: _name, hint: 'Full Name', icon: Icons.person_outline),
          const SizedBox(height: 14),
          AuthField(
              controller: _email,
              hint: 'Email Address',
              icon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 14),
          AuthField(controller: _username, hint: 'Username', icon: Icons.alternate_email),
          const SizedBox(height: 14),
          AuthField(
              controller: _password,
              hint: 'Password (at least 6 characters)',
              icon: Icons.lock_outline,
              password: true),
          const SizedBox(height: 18),
          const Text('I am a:',
              style: TextStyle(color: C.navy, fontSize: 12, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          PillTabs(
            labels: const ['Player', 'Organizer'],
            selected: _role,
            onChanged: (i) => setState(() => _role = i),
          ),
          const SizedBox(height: 6),
          Text(
            _role == 0
                ? 'View schedules, standings and live scores.'
                : 'For SK officials and tournament organizers. You start as a Player until an organizer approves your request.',
            style: const TextStyle(color: C.grey, fontSize: 11),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(_error!, style: const TextStyle(color: C.red, fontSize: 12)),
            ),
          const SizedBox(height: 18),
          PrimaryButton(_busy ? 'Please wait...' : 'Sign Up',
              onPressed: _busy ? () {} : _submit),
          const SizedBox(height: 14),
          Center(
            child: TextButton(
              onPressed: () => context.go('/login'),
              child: const Text('Already have an account? Log In',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: C.grey, fontSize: 13)),
            ),
          ),
        ]),
      ),
    );
  }
}
