import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets.dart';

/// Organizer: change the score, change the quarter/set, finish the match.
class UpdateScoreScreen extends StatelessWidget {
  const UpdateScoreScreen({super.key, required this.matchId});
  final String matchId;

  Widget _scoreButton(String label, Color color, VoidCallback? onPressed) =>
      SizedBox(
        width: 54,
        height: 40,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: EdgeInsets.zero,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
        ),
      );

  Widget _side(LiveMatch m, bool home) {
    final name = home ? m.home : m.away;
    final score = home ? m.homeScore : m.awayScore;
    return Expanded(
      child: AppCard(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          Shield(teamByName(name).color, size: 28),
          const SizedBox(height: 6),
          Text(name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: C.navy, fontSize: 12, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('$score',
              style: const TextStyle(
                  color: C.navy, fontSize: 40, fontWeight: FontWeight.w800)),
          if (m.sport == 'Volleyball')
            Text('Sets: ${home ? m.homeSets : m.awaySets}',
                style: const TextStyle(color: C.grey, fontSize: 11)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: [
              for (final inc in incrementsFor(m.sport))
                _scoreButton(
                  '+$inc',
                  C.orange,
                  m.isFinal ? null : () => store.changeScore(m, home: home, by: inc),
                ),
              _scoreButton(
                '−1',
                C.navy,
                m.isFinal ? null : () => store.changeScore(m, home: home, by: -1),
              ),
            ],
          ),
        ]),
      ),
    );
  }

  Future<void> _confirmFinish(BuildContext context, LiveMatch m) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Finish match?'),
        content: Text(m.sport == 'Volleyball'
            ? 'Sets won: ${m.home} ${m.homeSets} - ${m.awaySets} ${m.away}.\n\nA set that is still running counts for the team that is ahead. The team with more sets wins and the Standings will be updated.'
            : 'Final score: ${m.home} ${m.homeScore} - ${m.awayScore} ${m.away}.\n\nStandings will be updated.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Finish',
                  style: TextStyle(color: C.orange, fontWeight: FontWeight.w800))),
        ],
      ),
    );
    if (ok == true) {
      final done = await store.finishMatch(m);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(done
                ? 'Match finished. Standings updated.'
                : 'Could not finish the match. Check your internet and try again.')));
      }
    }
  }

  Future<void> _endSet(BuildContext context, LiveMatch m) async {
    final problem = await store.endSet(m);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(problem ?? 'Set ended. The next set has started.')));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final m = store.matchById(matchId);
        return Scaffold(
          appBar: navyAppBar(context, 'Update Score', fallback: '/organizer'),
          body: m == null
              ? const Center(child: Text('Match not found'))
              : ListView(padding: const EdgeInsets.all(16), children: [
                  Text(m.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: C.navy, fontSize: 14, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(m.status,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: C.grey, fontSize: 11)),
                  const SizedBox(height: 14),
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _side(m, true),
                    _side(m, false),
                  ]),
                  const SizedBox(height: 16),
                  Text(m.sport == 'Volleyball'
                          ? 'Set'
                          : (m.sport == 'Football' ? 'Half' : 'Quarter'),
                      style: const TextStyle(
                          color: C.navy, fontSize: 12, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    for (final p in periodsFor(m.sport))
                      ChoiceChip(
                        label: Text(p),
                        selected: m.period == p,
                        selectedColor: C.orange,
                        labelStyle: TextStyle(
                            color: m.period == p ? Colors.white : C.navy,
                            fontSize: 12),
                        onSelected: m.isFinal ? null : (_) => store.setPeriod(m, p),
                      ),
                  ]),
                  if (m.sport == 'Volleyball' && !m.isFinal) ...[
                    const SizedBox(height: 14),
                    const Text(
                        'The big number is the points in this set. Tap End Set when a set is done: the team with more points wins the set.',
                        style: TextStyle(color: C.grey, fontSize: 11)),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 44,
                      child: OutlinedButton(
                        onPressed: () => _endSet(context, m),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: C.navy),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('End Set',
                            style: TextStyle(
                                color: C.navy,
                                fontSize: 13,
                                fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  PrimaryButton(
                    m.isFinal ? 'Done' : 'Finish Match',
                    onPressed: m.isFinal
                        ? () => context.pop()
                        : () => _confirmFinish(context, m),
                  ),
                ]),
        );
      },
    );
  }
}
