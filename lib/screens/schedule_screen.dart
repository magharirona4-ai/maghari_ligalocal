import 'package:flutter/material.dart';
import '../data.dart';
import '../dates.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  int _day = 0; // 0 = today, 1 = tomorrow, ...

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final key = dateKey(dayFromToday(_day));
        final dayGames = games.where((g) => g.dayKey == key).toList();
        return Scaffold(
          appBar: navyAppBar(context, 'Game Schedule'),
          body: ListView(padding: const EdgeInsets.all(16), children: [
            PillTabs(
              labels: [for (var i = 0; i < 4; i++) dayLabel(i)],
              selected: _day,
              onChanged: (i) => setState(() => _day = i),
            ),
            const SizedBox(height: 16),
            if (dayGames.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 40),
                child: Center(
                  child: Text('No games scheduled for this day.',
                      style: TextStyle(color: C.grey, fontSize: 12)),
                ),
              )
            else
              for (final g in dayGames) GameCard(g),
          ]),
        );
      },
    );
  }
}
