import 'package:flutter/material.dart';
import '../data.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets.dart';

class LiveScoreboardScreen extends StatelessWidget {
  const LiveScoreboardScreen({super.key, required this.matchId});
  final String matchId;

  Widget _teamColumn(String name, int score) => Expanded(
        child: Column(children: [
          Shield(teamByName(name).color, size: 30),
          const SizedBox(height: 8),
          Text(name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Text('$score',
              style: const TextStyle(
                  color: Colors.white, fontSize: 38, fontWeight: FontWeight.w800)),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final m = store.matchById(matchId);
        return Scaffold(
          appBar: navyAppBar(context, 'Live Scoreboard', fallback: '/standings'),
          body: m == null
              ? const Center(child: Text('Match not found'))
              : ListView(children: [
                  Container(
                    color: C.navy2,
                    padding: const EdgeInsets.symmetric(vertical: 22),
                    child: Column(children: [
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                            color: m.isFinal ? C.grey : C.red,
                            borderRadius: BorderRadius.circular(14)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          if (!m.isFinal) ...const [
                            Icon(Icons.circle, size: 8, color: Colors.white),
                            SizedBox(width: 6),
                          ],
                          Text(m.isFinal ? 'FINAL' : 'LIVE',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700)),
                        ]),
                      ),
                      const SizedBox(height: 18),
                      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        _teamColumn(m.home, m.homeShown),
                        const Padding(
                          padding: EdgeInsets.only(top: 44),
                          child: Text('VS',
                              style: TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                        _teamColumn(m.away, m.awayShown),
                      ]),
                      const SizedBox(height: 14),
                      Text(m.status,
                          style: const TextStyle(color: Colors.white, fontSize: 11)),
                    ]),
                  ),
                  if (m.stats != null)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: AppCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(children: [
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Team Stats',
                                style: TextStyle(
                                    color: C.navy,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800)),
                          ),
                          const SizedBox(height: 14),
                          Row(children: [
                            Text(m.home,
                                style: const TextStyle(
                                    color: C.navy,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700)),
                            const Spacer(),
                            Text(m.away,
                                style: const TextStyle(
                                    color: C.navy,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700)),
                          ]),
                          for (final s in m.stats!)
                            Container(
                              margin: const EdgeInsets.only(top: 10),
                              padding: const EdgeInsets.only(top: 12),
                              decoration: const BoxDecoration(
                                  border: Border(top: BorderSide(color: C.navy))),
                              child: Row(children: [
                                Expanded(
                                  child: Text(s.$1,
                                      style: const TextStyle(
                                          color: C.navy,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700)),
                                ),
                                Text(s.$2,
                                    style: const TextStyle(color: C.grey, fontSize: 10)),
                                Expanded(
                                  child: Text(s.$3,
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(
                                          color: C.navy,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700)),
                                ),
                              ]),
                            ),
                        ]),
                      ),
                    ),
                ]),
        );
      },
    );
  }
}
