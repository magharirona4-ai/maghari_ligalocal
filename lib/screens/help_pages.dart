import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';

/// FAQs, Terms and Privacy pages. Edit the text below to match your league.

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  static const _faqs = [
    (
      'How do I see when my game is?',
      'Open the Schedule tab. Games are grouped by day. Tap a day at the top to see its games.'
    ),
    (
      'How do the standings work?',
      'Teams earn points for wins. Teams with equal points are ranked by more wins, then fewer losses. Use the Overall, Men\'s and Women\'s tabs to switch views.'
    ),
    (
      'How do I become an Organizer?',
      'Choose Organizer when you sign up. Your account stays a Player until an existing Organizer approves your request.'
    ),
    (
      'I forgot my password.',
      'On the Log In screen, tap Forgot Password and enter your email. We will send you a reset link.'
    ),
    (
      'How do I change my password?',
      'Go to More, then Settings, then Change Password.'
    ),
    (
      'A score looks wrong. What do I do?',
      'Scores are updated by the Organizers. Tell the Organizer in charge of your game, or use Contact Us in Help & Support.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: navyAppBar(context, 'FAQs', fallback: '/more/help'),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        for (final f in _faqs)
          AppCard(
            borderColor: C.border,
            padding: EdgeInsets.zero,
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 14),
                childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                title: Text(f.$1,
                    style: const TextStyle(
                        color: C.navy, fontSize: 12, fontWeight: FontWeight.w700)),
                children: [
                  Text(f.$2, style: const TextStyle(color: C.grey, fontSize: 12)),
                ],
              ),
            ),
          ),
      ]),
    );
  }
}

class _TextPage extends StatelessWidget {
  const _TextPage(this.title, this.sections);
  final String title;
  final List<(String, String)> sections;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: navyAppBar(context, title, fallback: '/more/help'),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        for (final s in sections) ...[
          Text(s.$1,
              style: const TextStyle(
                  color: C.navy, fontSize: 14, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(s.$2,
              style: const TextStyle(color: C.grey, fontSize: 12, height: 1.5)),
          const SizedBox(height: 18),
        ],
      ]),
    );
  }
}

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) => const _TextPage('Terms & Conditions', [
        (
          'Using LigaLocal',
          'LigaLocal shows schedules, scores and standings for the barangay sports festival. By creating an account you agree to use the app fairly and honestly.'
        ),
        (
          'Your account',
          'Keep your password private. You are responsible for what happens under your account. Give us a real name and email.'
        ),
        (
          'Organizers',
          'Organizers can create games, update scores and manage teams. Organizer access is given only after approval and can be removed if it is misused.'
        ),
        (
          'Scores and schedules',
          'We try to keep results accurate, but schedules and scores can change. The decision of the league officials is final.'
        ),
        (
          'Changes',
          'We may update these terms. Continuing to use the app means you accept the updated terms.'
        ),
      ]);
}

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) => const _TextPage('Privacy Policy', [
        (
          'What we keep',
          'Your full name, email address, username and account type (Player or Organizer). We keep this so you can log in and so Organizers can manage the league.'
        ),
        (
          'Where it is kept',
          'Your data is stored with Google Firebase (Authentication and Firestore).'
        ),
        (
          'Who can see it',
          'Your name may be shown to Organizers, for example when you request Organizer access. We do not sell your information.'
        ),
        (
          'Your choices',
          'You can change your name and password in the app. To delete your account, contact the league organizers.'
        ),
      ]);
}
