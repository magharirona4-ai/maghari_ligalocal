import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data.dart';
import '../theme.dart';
import '../widgets.dart';

class MyTeamsScreen extends StatelessWidget {
  const MyTeamsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: navyAppBar(context, 'My Teams', fallback: '/more'),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        for (final t in myTeams)
          AppCard(
            borderColor: C.border,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            onTap: () => context.go('/standings/team/${t.teamId}'),
            child: Row(children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: t.color,
                child: const Icon(Icons.emoji_events, color: C.orange, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(teamById(t.teamId).name,
                      style: const TextStyle(
                          color: C.navy, fontSize: 13, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(t.sport, style: const TextStyle(color: C.grey, fontSize: 10)),
                ]),
              ),
              const Icon(Icons.chevron_right, size: 18, color: C.navy),
            ]),
          ),
      ]),
    );
  }
}
