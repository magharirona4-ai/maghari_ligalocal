import 'package:flutter/material.dart';
import '../auth_state.dart';
import '../auth_widgets.dart';
import '../theme.dart';
import '../widgets.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _name =
      TextEditingController(text: auth.fullName);
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final err = await auth.updateName(_name.text);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = err;
    });
    if (err == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Profile saved.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: navyAppBar(context, 'My Profile', fallback: '/more'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Full name',
              style: TextStyle(
                  color: C.navy, fontSize: 12, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          AuthField(
              controller: _name,
              light: true,
              hint: 'Full name',
              icon: Icons.person_outline),
          const SizedBox(height: 16),
          const Text('Email',
              style: TextStyle(
                  color: C.navy, fontSize: 12, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          AppCard(
            borderColor: C.border,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(children: [
              const Icon(Icons.mail_outline, size: 18, color: C.grey),
              const SizedBox(width: 10),
              Expanded(
                child: Text(auth.email,
                    style: const TextStyle(color: C.grey, fontSize: 14)),
              ),
            ]),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 6),
              child: Text(_error!, style: const TextStyle(color: C.red, fontSize: 12)),
            ),
          const SizedBox(height: 12),
          PrimaryButton(_busy ? 'Please wait...' : 'Save',
              onPressed: _busy ? () {} : _save),
        ]),
      ),
    );
  }
}
