import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets.dart';

class TeamDetailsScreen extends StatefulWidget {
  const TeamDetailsScreen({super.key, required this.teamId});
  final String teamId;

  @override
  State<TeamDetailsScreen> createState() => _TeamDetailsScreenState();
}

class _TeamDetailsScreenState extends State<TeamDetailsScreen> {
  int _tab = 0;

  static const _demoRecent = [
    ('Taytay United vs Bgy. Maasin', '62 - 58'),
    ('Taytay United vs San Isidro', '78 - 65'),
    ('Poblacion vs Taytay United', '70 - 68'),
  ];

  Widget _statBox(String label, String value) => Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: C.border),
          ),
          child: Column(children: [
            Text(label, style: const TextStyle(color: C.grey, fontSize: 11)),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(
                    color: C.navy, fontSize: 20, fontWeight: FontWeight.w800)),
          ]),
        ),
      );

  Widget _recentCard(Team team, String title, String score) => AppCard(
        borderColor: C.border,
        padding: const EdgeInsets.all(12),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Shield(team.color, size: 14),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(title,
                      style: const TextStyle(
                          color: C.navy, fontSize: 11, fontWeight: FontWeight.w700)),
                ),
              ]),
              const SizedBox(height: 6),
              const Text('Final', style: TextStyle(color: C.grey, fontSize: 10)),
            ]),
          ),
          Text(score,
              style: const TextStyle(
                  color: C.navy, fontSize: 12, fontWeight: FontWeight.w800)),
        ]),
      );

  List<Widget> _overview(Team team) {
    final st = standingOf(team.id);
    final finished = store.matches
        .where((m) => m.isFinal && (m.home == team.name || m.away == team.name))
        .toList();
    final hasDemo = team.id == 'taytay-united';
    return [
      const Text('Team Stats',
          style: TextStyle(color: C.navy, fontSize: 14, fontWeight: FontWeight.w800)),
      const SizedBox(height: 10),
      Row(children: [
        _statBox('W', '${st.w}'),
        _statBox('L', '${st.l}'),
        _statBox('Pts', '${st.pts}'),
      ]),
      const SizedBox(height: 20),
      const Text('Recent Matches',
          style: TextStyle(color: C.navy, fontSize: 14, fontWeight: FontWeight.w800)),
      const SizedBox(height: 10),
      if (finished.isEmpty && !hasDemo)
        const Text('No recent matches yet.',
            style: TextStyle(color: C.grey, fontSize: 12)),
      for (final m in finished) _recentCard(team, '${m.home} vs ${m.away}', m.score),
      if (hasDemo)
        for (final r in _demoRecent) _recentCard(team, r.$1, r.$2),
    ];
  }

  Future<void> _addPlayer(Team team) async {
    final player = await showDialog<_NewPlayerData>(
      context: context,
      builder: (dialogContext) => const _AddPlayerDialog(),
    );

    if (player == null || !mounted) return;

    try {
      await FirebaseFirestore.instance
          .collection('teams')
          .doc(team.id)
          .collection('players')
          .add({
        'name': player.name,
        'jerseyNumber': player.jerseyNumber,
        'position': player.position,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Player added successfully.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not add player: $e'),
          ),
        );
      }
    }
  }

  Widget _playersList(Team team) {
    final playersRef = FirebaseFirestore.instance
        .collection('teams')
        .doc(team.id)
        .collection('players')
        .orderBy('createdAt');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text('Players List',
                  style: TextStyle(
                      color: C.navy, fontSize: 14, fontWeight: FontWeight.w800)),
            ),
            ElevatedButton.icon(
              onPressed: () => _addPlayer(team),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Player'),
              style: ElevatedButton.styleFrom(
                backgroundColor: C.orange,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: playersRef.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text('Unable to load players. Check Firestore rules.',
                  style: TextStyle(color: C.red, fontSize: 12));
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data!.docs;
            if (docs.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: C.border),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(children: [
                  Icon(Icons.groups_outlined, color: C.grey, size: 34),
                  SizedBox(height: 8),
                  Text('No players added yet.',
                      style: TextStyle(color: C.grey, fontSize: 12)),
                  Text('Tap Add Player to create the team roster.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: C.grey, fontSize: 11)),
                ]),
              );
            }

            return Column(
              children: [
                for (var i = 0; i < docs.length; i++)
                  Card(
                    color: Colors.white,
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: C.border),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: C.navy,
                        child: Text(
                          (docs[i].data()['jerseyNumber'] as String?)?.isNotEmpty == true
                              ? docs[i].data()['jerseyNumber'] as String
                              : '${i + 1}',
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                      ),
                      title: Text(
                        docs[i].data()['name'] as String? ?? 'Unnamed player',
                        style: const TextStyle(
                            color: C.navy, fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        (docs[i].data()['position'] as String?)?.isNotEmpty == true
                            ? docs[i].data()['position'] as String
                            : 'Player',
                        style: const TextStyle(color: C.grey, fontSize: 11),
                      ),
                      trailing: IconButton(
                        tooltip: 'Remove player',
                        icon: const Icon(Icons.delete_outline, color: C.red),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Remove Player?'),
                              content: const Text(
                                  'This player will be removed from this team roster.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('Remove',
                                      style: TextStyle(color: C.red)),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await docs[i].reference.delete();
                          }
                        },
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final team = teamById(widget.teamId);
        return Scaffold(
          appBar: navyAppBar(context, 'Team Details', fallback: '/standings'),
          body: ListView(children: [
            Container(
              color: C.navy2,
              padding: const EdgeInsets.all(20),
              child: Row(children: [
                const LogoMark(size: 48),
                const SizedBox(width: 14),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(team.name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text(team.barangay,
                      style: const TextStyle(color: Colors.white70, fontSize: 11)),
                ]),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                PillTabs(
                  labels: const ['Overview', 'Players'],
                  selected: _tab,
                  onChanged: (i) => setState(() => _tab = i),
                ),
                const SizedBox(height: 18),
                if (_tab == 0)
                  ..._overview(team)
                else
                  _playersList(team),
              ]),
            ),
          ]),
        );
      },
    );
  }
}


class _NewPlayerData {
  final String name;
  final String jerseyNumber;
  final String position;

  const _NewPlayerData({
    required this.name,
    required this.jerseyNumber,
    required this.position,
  });
}

class _AddPlayerDialog extends StatefulWidget {
  const _AddPlayerDialog();

  @override
  State<_AddPlayerDialog> createState() => _AddPlayerDialogState();
}

class _AddPlayerDialogState extends State<_AddPlayerDialog> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _jerseyController = TextEditingController();
  final _positionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _jerseyController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  void _savePlayer() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).pop(
      _NewPlayerData(
        name: _nameController.text.trim(),
        jerseyNumber: _jerseyController.text.trim(),
        position: _positionController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Add Player',
        style: TextStyle(
          color: C.navy,
          fontWeight: FontWeight.w800,
        ),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Player name',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter player name.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _jerseyController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Jersey number',
                ),
              ),
              TextFormField(
                controller: _positionController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Position',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _savePlayer,
          child: const Text('Save Player'),
        ),
      ],
    );
  }
}
