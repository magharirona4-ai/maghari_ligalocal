import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data.dart';
import '../dates.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets.dart';

/// Organizer home: update scores, create games, manage teams.
class OrganizerScreen extends StatelessWidget {
  const OrganizerScreen({super.key});

  Widget _heading(String text) => Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 10),
        child: Text(text,
            style: const TextStyle(
                color: C.navy, fontSize: 14, fontWeight: FontWeight.w800)),
      );

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) => Scaffold(
        appBar: navyAppBar(context, 'Organizer Panel', fallback: '/more'),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          if (store.teamsLoaded && teams.isEmpty)
            AppCard(
              borderColor: C.orange,
              margin: const EdgeInsets.only(bottom: 16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('No data yet',
                    style: TextStyle(
                        color: C.navy, fontSize: 14, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                const Text(
                    'Load the sample teams, schedule and matches to get started. Do this only once.',
                    style: TextStyle(color: C.grey, fontSize: 11)),
                const SizedBox(height: 12),
                PrimaryButton('Load sample data', onPressed: () async {
                  final ok = await store.seedSampleData();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(ok
                          ? 'Sample data loaded.'
                          : 'Could not load data. Check your internet.')));
                }),
              ]),
            ),
          if (standings.isNotEmpty &&
              standings.every((s) => s.mw + s.ml + s.ww + s.wl == 0))
            AppCard(
              borderColor: C.orange,
              margin: const EdgeInsets.only(bottom: 16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Men’s and Women’s standings are empty',
                    style: TextStyle(
                        color: C.navy, fontSize: 14, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                const Text(
                    'Load sample results for both divisions. This also resets the Overall standings to the sample totals.',
                    style: TextStyle(color: C.grey, fontSize: 11)),
                const SizedBox(height: 12),
                PrimaryButton('Load Men’s & Women’s sample', onPressed: () async {
                  final yes = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Load sample standings?'),
                      content: const Text(
                          'The Overall standings will be replaced by the sample totals (Men’s + Women’s).'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(false),
                            child: const Text('Cancel')),
                        TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(true),
                            child: const Text('Load',
                                style: TextStyle(
                                    color: C.orange, fontWeight: FontWeight.w800))),
                      ],
                    ),
                  );
                  if (yes != true) return;
                  final ok = await store.seedDivisionStandings();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(ok
                          ? 'Sample standings loaded.'
                          : 'Could not load. Check your internet.')));
                }),
              ]),
            ),
          PrimaryButton('Create Game',
              onPressed: () => context.push('/organizer/create-game')),
          const SizedBox(height: 10),
          SocialButton('Manage Teams', Icons.groups_outlined,
              onPressed: () => context.push('/organizer/teams')),
          const _OrganizerRequests(),
          _heading('Matches (tap to update score)'),
          for (final m in store.matches)
            AppCard(
              onTap: () => context.push('/organizer/score/${m.id}'),
              child: Row(children: [
                Icon(sportIcon(m.sport), size: 18, color: sportColor(m.sport)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${m.home} vs ${m.away}',
                        style: const TextStyle(
                            color: C.navy, fontSize: 12, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text('${m.title} • ${m.status}',
                        style: const TextStyle(color: C.grey, fontSize: 10)),
                  ]),
                ),
                Text(m.score,
                    style: const TextStyle(
                        color: C.navy, fontSize: 14, fontWeight: FontWeight.w800)),
                const SizedBox(width: 6),
                const Icon(Icons.chevron_right, size: 18, color: C.grey),
              ]),
            ),
          _heading('Scheduled Games'),
          if (games.isEmpty)
            const Text('No scheduled games.',
                style: TextStyle(color: C.grey, fontSize: 12))
          else
            for (final g in games)
              AppCard(
                borderColor: C.border,
                padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
                child: Row(children: [
                  Icon(sportIcon(g.sport), size: 18, color: sportColor(g.sport)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('${g.home} vs ${g.away}',
                          style: const TextStyle(
                              color: C.navy, fontSize: 12, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text('${g.sport} • ${divisionLabel(g.division)} • ${labelForKey(g.dayKey)} • ${g.time}',
                          style: const TextStyle(color: C.grey, fontSize: 10)),
                    ]),
                  ),
                  TextButton(
                    onPressed: () {
                      store.startGame(g);
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Game started (0 - 0)')));
                    },
                    child: const Text('Start',
                        style: TextStyle(
                            color: C.orange, fontSize: 12, fontWeight: FontWeight.w800)),
                  ),
                ]),
              ),
        ]),
      ),
    );
  }
}


/// People who asked to become an organizer. Any organizer can approve them.
class _OrganizerRequests extends StatelessWidget {
  const _OrganizerRequests();

  Future<void> _answer(BuildContext context,
      DocumentReference<Map<String, dynamic>> ref, bool approve) async {
    try {
      await ref.update(approve
          ? {'role': 'organizer', 'organizerRequest': 'approved'}
          : {'organizerRequest': 'declined'});
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(approve ? 'Approved as organizer.' : 'Request declined.')));
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Could not save. Check your internet and try again.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('organizerRequest', isEqualTo: 'pending')
          .snapshots(),
      builder: (context, snap) {
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) return const SizedBox.shrink();
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Padding(
            padding: EdgeInsets.only(top: 18, bottom: 10),
            child: Text('Organizer requests',
                style: TextStyle(
                    color: C.navy, fontSize: 14, fontWeight: FontWeight.w800)),
          ),
          for (final d in docs)
            AppCard(
              borderColor: C.orange,
              padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
              child: Row(children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text((d.data()['fullName'] as String?) ?? 'Unknown',
                        style: const TextStyle(
                            color: C.navy, fontSize: 12, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 3),
                    Text((d.data()['email'] as String?) ?? '',
                        style: const TextStyle(color: C.grey, fontSize: 10)),
                  ]),
                ),
                TextButton(
                  onPressed: () => _answer(context, d.reference, false),
                  child: const Text('Decline',
                      style: TextStyle(color: C.grey, fontSize: 12)),
                ),
                TextButton(
                  onPressed: () => _answer(context, d.reference, true),
                  child: const Text('Approve',
                      style: TextStyle(
                          color: C.orange, fontSize: 12, fontWeight: FontWeight.w800)),
                ),
              ]),
            ),
        ]);
      },
    );
  }
}
