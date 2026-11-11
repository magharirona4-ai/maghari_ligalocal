import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';
import '../widgets.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const _faqs = [
    (
      'How do I view game schedules?',
      'Open the Schedule tab to see the listed games, teams, dates, and times.'
    ),
    (
      'Where can I see team rankings?',
      'Open the Standings tab to view the current team standings.'
    ),
    (
      'How do I view my teams?',
      'Open Profile, then select My Teams.'
    ),
    (
      'I cannot log in. What should I do?',
      'Check your email and password. If you forgot your password, use Forgot Password on the login screen.'
    ),
  ];

  static const _items = [
    (Icons.help_outline, 'FAQs', 'Find answers to common questions'),
    (Icons.mail_outline, 'Contact Us', 'Get in touch with our support team'),
    (Icons.error_outline, 'Report a Problem', 'Help us improve the app'),
    (Icons.article_outlined, 'Terms & Conditions', 'Read our terms and conditions'),
    (Icons.privacy_tip_outlined, 'Privacy Policy', 'How we handle your data'),
  ];

  void _showFaqs(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Frequently Asked Questions'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final faq in _faqs)
                ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: Text(faq.$1,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(faq.$2),
                    ),
                  ],
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showInfo(BuildContext context, String title, String body) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(child: Text(body)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _contactUs(BuildContext context) {
    _showInfo(
      context,
      'Contact Us',
      'For assistance with LigaLocal, please contact your barangay sports festival organizer or the app developer through the contact details provided by your school or project team. No support email or phone number is configured in this app yet.',
    );
  }

  void _reportProblem(BuildContext context) {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Report a Problem'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Describe the problem you encountered...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Your report was not sent. A report submission service is not connected yet.',
                  ),
                ),
              );
            },
            child: const Text('Done'),
          ),
        ],
      ),
    ).then((_) => controller.dispose());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Long-press the title to open the About screen (it has no button in Figma).
      appBar: navyAppBar(context, 'Help & Support',
          fallback: '/more', onTitleLongPress: () => context.push('/about')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        for (final i in _items)
          AppCard(
            borderColor: C.border,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            onTap: () {
              switch (i.$2) {
                case 'FAQs':
                  _showFaqs(context);
                  break;
                case 'Contact Us':
                  _contactUs(context);
                  break;
                case 'Report a Problem':
                  _reportProblem(context);
                  break;
                case 'Terms & Conditions':
                  _showInfo(
                    context,
                    'Terms & Conditions',
                    'LigaLocal provides sports festival schedules, team information, standings, and match updates for informational purposes. Users should follow the official instructions of their barangay sports festival organizers. Sample or unavailable information should not be treated as an official result. The app is a project application and its features may depend on internet access and connected services.',
                  );
                  break;
                case 'Privacy Policy':
                  _showInfo(
                    context,
                    'Privacy Policy',
                    'LigaLocal uses account information such as your name and email to provide sign-in and profile features. Account and application data may be stored using Firebase services configured for this project. Do not share your password with anyone. Contact the project developer or organizer for questions about your account data. This is a basic in-app notice, not a substitute for a reviewed production privacy policy.',
                  );
                  break;
              }
            },
            child: Row(children: [
              Icon(i.$1, size: 16, color: C.navy),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(i.$2,
                      style: const TextStyle(
                          color: C.navy,
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(i.$3,
                      style: const TextStyle(color: C.grey, fontSize: 9)),
                ]),
              ),
              const Icon(Icons.chevron_right, size: 18, color: C.grey),
            ]),
          ),
      ]),
    );
  }
}
