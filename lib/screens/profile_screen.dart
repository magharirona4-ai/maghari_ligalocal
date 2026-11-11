import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../auth_state.dart';
import '../theme.dart';
import '../widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Widget _item(IconData icon, String label, VoidCallback onTap) => AppCard(
        borderColor: C.border,
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        onTap: onTap,
        child: Row(children: [
          Icon(icon, size: 16, color: C.navy),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    color: C.navy, fontSize: 12, fontWeight: FontWeight.w700)),
          ),
          const Icon(Icons.chevron_right, size: 18, color: C.grey),
        ]),
      );

  Future<void> _editProfile(BuildContext context) async {
    final controller = TextEditingController(text: auth.fullName);
    final formKey = GlobalKey<FormState>();
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('My Profile'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Full name'),
            validator: (value) =>
                value == null || value.trim().isEmpty ? 'Enter your name.' : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(dialogContext, controller.text.trim());
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null || !context.mounted) return;

    final error = await auth.updateName(name);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? 'Profile name updated successfully.')),
    );
  }

  Future<void> _privacySecurity(BuildContext context) async {
    final email = auth.email;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Privacy & Security'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Signed-in email'),
            const SizedBox(height: 5),
            SelectableText(email.isEmpty ? 'No email available' : email),
            const SizedBox(height: 14),
            const Text(
              'To reset your password, Firebase will send a secure reset link to your registered email address.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: email.isEmpty
                ? null
                : () => Navigator.pop(dialogContext, true),
            child: const Text('Send reset link'),
          ),
        ],
      ),
    );
    if (confirm != true || !context.mounted) return;

    final error = await auth.sendPasswordReset(email);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? 'Password reset link sent. Check your email.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: auth,
      builder: (context, _) => Scaffold(
        appBar: navyAppBar(context, 'Profile'),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          AppCard(
            borderColor: C.border,
            padding: const EdgeInsets.all(18),
            margin: const EdgeInsets.only(bottom: 14),
            child: Row(children: [
              const CircleAvatar(radius: 16, backgroundColor: C.navy),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(auth.fullName.isEmpty ? 'Your name' : auth.fullName,
                      style: const TextStyle(
                          color: C.navy,
                          fontSize: 14,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(auth.email,
                      style: const TextStyle(color: C.grey, fontSize: 10)),
                  const SizedBox(height: 4),
                  Text(
                      auth.isOrganizer
                          ? 'Organizer account'
                          : (auth.organizerPending
                              ? 'Player account • Organizer request pending'
                              : 'Player account'),
                      style: const TextStyle(
                          color: C.green,
                          fontSize: 10,
                          fontWeight: FontWeight.w700)),
                ]),
              ),
            ]),
          ),
          if (auth.isOrganizer)
            _item(Icons.admin_panel_settings_outlined, 'Organizer Panel',
                () => context.push('/organizer')),
          _item(Icons.person, 'My Profile', () => _editProfile(context)),
          _item(Icons.groups_outlined, 'My Teams',
              () => context.push('/more/my-teams')),
          _item(Icons.notifications_none, 'Notifications',
              () => context.push('/more/settings')),
          _item(Icons.lock_outline, 'Privacy & Security',
              () => _privacySecurity(context)),
          _item(Icons.help_outline, 'Help & Support',
              () => context.push('/more/help')),
          const SizedBox(height: 22),
          SizedBox(
            height: 44,
            child: OutlinedButton(
              onPressed: auth.logout,
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: C.red),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Log Out',
                  style: TextStyle(
                      color: C.red, fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          ),
        ]),
      ),
    );
  }
}
