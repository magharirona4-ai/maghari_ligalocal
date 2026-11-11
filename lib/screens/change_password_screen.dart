import 'package:flutter/material.dart';
import '../auth_state.dart';
import '../auth_widgets.dart';
import '../theme.dart';
import '../widgets.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _current = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _current.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_current.text.isEmpty || _new.text.isEmpty || _confirm.text.isEmpty) {
      setState(() => _error = 'Fill in all the boxes.');
      return;
    }
    if (_new.text.length < 6) {
      setState(() => _error = 'New password must be at least 6 characters.');
      return;
    }
    if (_new.text != _confirm.text) {
      setState(() => _error = 'The new passwords do not match.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final err = await auth.changePassword(_current.text, _new.text);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = err;
    });
    if (err == null) {
      _current.clear();
      _new.clear();
      _confirm.clear();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password changed.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: navyAppBar(context, 'Change Password', fallback: '/more/settings'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Enter your current password, then choose a new one.',
              style: TextStyle(color: C.grey, fontSize: 12)),
          const SizedBox(height: 18),
          AuthField(
              controller: _current,
              light: true,
              hint: 'Current password',
              icon: Icons.lock_outline,
              password: true),
          const SizedBox(height: 12),
          AuthField(
              controller: _new,
              light: true,
              hint: 'New password',
              icon: Icons.lock_reset,
              password: true),
          const SizedBox(height: 12),
          AuthField(
              controller: _confirm,
              light: true,
              hint: 'Confirm new password',
              icon: Icons.lock_reset,
              password: true),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(_error!, style: const TextStyle(color: C.red, fontSize: 12)),
            ),
          const SizedBox(height: 18),
          PrimaryButton(_busy ? 'Please wait...' : 'Save Password',
              onPressed: _busy ? () {} : _save),
        ]),
      ),
    );
  }
}
