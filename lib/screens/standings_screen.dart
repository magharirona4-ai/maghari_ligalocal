import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets.dart';

class StandingsScreen extends StatefulWidget {
  const StandingsScreen({super.key});

  @override
  State<StandingsScreen> createState() => _StandingsScreenState();
}

class _StandingsScreenState extends State<StandingsScreen> {
  int _tab = 0; // 0 = Overall, 1 = Men's, 2 = Women's

  Widget _cell(String text, double width, {bool bold = true, Color? color}) =>
      SizedBox(
        width: width,
        child: Text(text,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: color ?? C.navy,
                fontSize: 11,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w400)),
      );

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        // Rank: points, then wins, then fewer losses (for the chosen tab)
        final rows = [...standings];
        rows.sort((a, b) {
          var c = b.ptsFor(_tab).compareTo(a.ptsFor(_tab));
          if (c != 0) return c;
          c = b.winsFor(_tab).compareTo(a.winsFor(_tab));
          if (c != 0) return c;
          c = a.lossesFor(_tab).compareTo(b.lossesFor(_tab));
          if (c != 0) return c;
          return a.teamId.compareTo(b.teamId);
        });
        final noGamesYet = rows.every(
            (s) => s.winsFor(_tab) + s.lossesFor(_tab) == 0);

        return Scaffold(
          appBar: navyAppBar(context, 'Standings Board'),
          body: ListView(padding: const EdgeInsets.all(16), children: [
            PillTabs(
              labels: const ['Overall', "Men's", "Women's"],
              selected: _tab,
              onChanged: (i) => setState(() => _tab = i),
            ),
            const SizedBox(height: 16),

            // Table header
            Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                  color: C.navy, borderRadius: BorderRadius.circular(8)),
              child: Row(children: [
                _cell('#', 28, color: Colors.white),
                const Expanded(
                  child: Text('Team',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
                ),
                _cell('W', 32, color: Colors.white),
                _cell('L', 32, color: Colors.white),
                _cell('Pts', 40, color: Colors.white),
              ]),
            ),
            const SizedBox(height: 6),

            // Rows
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: C.navy),
              ),
              child: Column(children: [
                for (var i = 0; i < rows.length; i++)
                  InkWell(
                    onTap: () => context.push('/standings/team/${rows[i].teamId}'),
                    child: Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: i == 0
                            ? null
                            : const Border(top: BorderSide(color: C.navy)),
                      ),
                      child: Row(children: [
                        _cell('${i + 1}', 28),
                        Icon(Icons.circle,
                            size: 10, color: teamById(rows[i].teamId).color),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(teamById(rows[i].teamId).name,
                              style: const TextStyle(
                                  color: C.navy,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700)),
                        ),
                        _cell('${rows[i].winsFor(_tab)}', 32),
                        _cell('${rows[i].lossesFor(_tab)}', 32),
                        _cell('${rows[i].ptsFor(_tab)}', 40),
                      ]),
                    ),
                  ),
              ]),
            ),
            if (noGamesYet && rows.isNotEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 14),
                child: Text('No finished games yet in this division.',
                    style: TextStyle(color: C.grey, fontSize: 11)),
              ),
          ]),
        );
      },
    );
  }
}
