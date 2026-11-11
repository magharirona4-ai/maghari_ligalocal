import 'package:flutter/material.dart';
import '../data.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets.dart';

/// Organizer: see all teams and add new ones.
class ManageTeamsScreen extends StatelessWidget {
  const ManageTeamsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) => Scaffold(
        appBar: navyAppBar(context, 'Manage Teams', fallback: '/organizer'),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          PrimaryButton('Add Team',
              onPressed: () => showDialog<void>(
                    context: context,
                    builder: (_) => const _AddTeamDialog(),
                  )),
          const SizedBox(height: 16),
          for (final t in teams)
            AppCard(
              borderColor: C.border,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: t.color,
                  child: const Icon(Icons.emoji_events, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(t.name,
                        style: const TextStyle(
                            color: C.navy, fontSize: 13, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 3),
                    Text(t.barangay,
                        style: const TextStyle(color: C.grey, fontSize: 10)),
                  ]),
                ),
              ]),
            ),
        ]),
      ),
    );
  }
}

class _AddTeamDialog extends StatefulWidget {
  const _AddTeamDialog();

  @override
  State<_AddTeamDialog> createState() => _AddTeamDialogState();
}

class _AddTeamDialogState extends State<_AddTeamDialog> {
  final _name = TextEditingController();
  final _barangay = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _barangay.dispose();
    super.dispose();
  }

  void _add() {
    if (store.addTeam(_name.text, _barangay.text)) {
      Navigator.of(context).pop();
    } else {
      setState(() => _error = 'Enter a team name that is not used yet.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Team'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(
          controller: _name,
          decoration: InputDecoration(labelText: 'Team name', errorText: _error),
        ),
        TextField(
          controller: _barangay,
          decoration: const InputDecoration(labelText: 'Barangay'),
        ),
      ]),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        TextButton(
            onPressed: _add,
            child: const Text('Add',
                style: TextStyle(color: C.orange, fontWeight: FontWeight.w800))),
      ],
    );
  }
}
