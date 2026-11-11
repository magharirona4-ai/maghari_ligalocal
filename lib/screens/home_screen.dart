
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../auth_state.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets.dart';
import '../language_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _t(String english, String filipino) {
    return languageController.translate(english, filipino);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        store,
        auth,
        languageController,
      ]),
      builder: (context, _) {
        final tiles = <(String, IconData, VoidCallback)>[
          (_t('Game', 'Laro'), Icons.grid_view,
              () => context.go('/schedule')),
          (_t('Standing', 'Klasipikasyon'), Icons.emoji_events_outlined,
              () => context.go('/standings')),
          (_t('Live', 'Live'), Icons.sensors,
              () => context.go('/standings/live/1')),
          (_t('My Teams', 'Aking mga Koponan'), Icons.groups_outlined,
              () => context.go('/more/my-teams')),
          (_t('Profile', 'Profile'), Icons.person_outline,
              () => context.go('/more')),
          (_t('Settings', 'Mga Setting'), Icons.settings_outlined,
              () => context.go('/more/settings')),
        ];

        final ongoing =
            store.matches.where((m) => m.onHome && !m.isFinal).toList();

        return Scaffold(
          body: Column(
            children: [
              // Navy header
              Container(
                width: double.infinity,
                color: C.navy,
                padding: EdgeInsets.fromLTRB(
                  20,
                  MediaQuery.of(context).padding.top + 12,
                  20,
                  20,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              LogoMark(size: 22),
                              SizedBox(width: 6),
                              Text(
                                'LigaLocal',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            '${_t('Welcome', 'Maligayang pagbabalik')}, ${auth.firstName}!',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _t(
                              "Let's make it happen!",
                              'Sama-sama nating gawin!',
                            ),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const CircleAvatar(
                      radius: 18,
                      backgroundColor: C.orange,
                      child: Icon(
                        Icons.sports_basketball,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),

              // Body
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (auth.isOrganizer)
                      AppCard(
                        borderColor: C.orange,
                        onTap: () => context.push('/organizer'),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.admin_panel_settings_outlined,
                              color: C.orange,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _t('Organizer Panel', 'Panel ng Organizer'),
                                    style: const TextStyle(
                                      color: C.navy,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _t(
                                      'Create games and update scores',
                                      'Gumawa ng mga laro at mag-update ng score',
                                    ),
                                    style: const TextStyle(
                                      color: C.grey,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              size: 18,
                              color: C.grey,
                            ),
                          ],
                        ),
                      ),

                    if (auth.organizerPending)
                      AppCard(
                        borderColor: C.border,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.hourglass_top,
                              color: C.orange,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _t(
                                  'Your organizer request is waiting for approval. You can view schedules and scores in the meantime.',
                                  'Naghihintay pa ng pag-apruba ang iyong kahilingan bilang organizer. Maaari mo munang tingnan ang mga iskedyul at score.',
                                ),
                                style: const TextStyle(
                                  color: C.grey,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    AppCard(
                      margin: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _t('Quick Access', 'Mabilisang Pag-access'),
                            style: const TextStyle(
                              color: C.navy,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 12),
                          GridView.count(
                            padding: EdgeInsets.zero,
                            crossAxisCount: 3,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: 1.25,
                            children: [
                              for (final t in tiles)
                                InkWell(
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: t.$3,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: C.navy),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          t.$2,
                                          size: 20,
                                          color: C.navy,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          t.$1,
                                          style: const TextStyle(
                                            color: C.navy,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        _t('Ongoing Matches', 'Mga Kasalukuyang Laro'),
                        style: const TextStyle(
                          color: C.navy,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),

                    if (ongoing.isEmpty)
                      Text(
                        _t(
                          'No ongoing matches right now.',
                          'Walang kasalukuyang nagaganap na laro.',
                        ),
                        style: const TextStyle(
                          color: C.grey,
                          fontSize: 12,
                        ),
                      )
                    else
                      for (final m in ongoing)
                        AppCard(
                          onTap: () =>
                              context.go('/standings/live/${m.id}'),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    sportIcon(m.sport),
                                    size: 14,
                                    color: sportColor(m.sport),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    m.title,
                                    style: const TextStyle(
                                      color: C.navy,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${m.home} vs ${m.away}',
                                style: const TextStyle(
                                  color: C.grey,
                                  fontSize: 10,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    m.periodText,
                                    style: const TextStyle(
                                      color: C.grey,
                                      fontSize: 10,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    m.score,
                                    style: const TextStyle(
                                      color: C.navy,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(width: 24),
                                ],
                              ),
                            ],
                          ),
                        ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
