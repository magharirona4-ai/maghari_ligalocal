
import 'package:flutter/material.dart';
import '../auth_state.dart';
import '../language_controller.dart';
import '../theme.dart';
import '../widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;
  String _theme = 'System default';

  String _t(String english, String filipino) {
    return languageController.translate(english, filipino);
  }

  Future<void> _changePassword() async {
    final current = TextEditingController();
    final next = TextEditingController();
    final confirm = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final values = await showDialog<List<String>>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(_t('Change Password', 'Palitan ang Password')),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: current,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: _t(
                      'Current password',
                      'Kasalukuyang password',
                    ),
                  ),
                  validator: (v) => v == null || v.isEmpty
                      ? _t(
                          'Enter your current password.',
                          'Ilagay ang kasalukuyang password.',
                        )
                      : null,
                ),
                TextFormField(
                  controller: next,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: _t('New password', 'Bagong password'),
                  ),
                  validator: (v) => v == null || v.length < 6
                      ? _t(
                          'Use at least 6 characters.',
                          'Gumamit ng hindi bababa sa 6 na character.',
                        )
                      : null,
                ),
                TextFormField(
                  controller: confirm,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: _t(
                      'Confirm new password',
                      'Kumpirmahin ang bagong password',
                    ),
                  ),
                  validator: (v) => v != next.text
                      ? _t(
                          'Passwords do not match.',
                          'Hindi magkatugma ang mga password.',
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(_t('Cancel', 'Kanselahin')),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(dialogContext, [
                  current.text,
                  next.text,
                ]);
              }
            },
            child: Text(_t('Update', 'I-update')),
          ),
        ],
      ),
    );

    current.dispose();
    next.dispose();
    confirm.dispose();

    if (values == null || !mounted) return;

    final error = await auth.changePassword(values[0], values[1]);

    if (!mounted) return;

    _showMessage(
      error ??
          _t(
            'Password changed successfully.',
            'Matagumpay na napalitan ang password.',
          ),
    );
  }

  Future<void> _chooseLanguage() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(_t('Choose Language', 'Pumili ng Wika')),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(dialogContext, 'English'),
            child: const Text('English'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(dialogContext, 'Filipino'),
            child: const Text('Filipino'),
          ),
        ],
      ),
    );

    if (selected != null && mounted) {
      languageController.changeLanguage(selected);

      _showMessage(
        selected == 'Filipino'
            ? 'Matagumpay na napalitan ang wika.'
            : 'Language changed successfully.',
      );
    }
  }

  Future<void> _chooseTheme() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(_t('Choose Theme', 'Pumili ng Tema')),
        children: [
          for (final theme in [
            'System default',
            'Light',
            'Dark',
          ])
            SimpleDialogOption(
              onPressed: () => Navigator.pop(dialogContext, theme),
              child: Text(
                theme == 'System default'
                    ? _t('System default', 'Default ng system')
                    : theme == 'Light'
                        ? _t('Light', 'Maliwanag')
                        : _t('Dark', 'Madilim'),
              ),
            ),
        ],
      ),
    );

    if (selected != null && mounted) {
      setState(() => _theme = selected);

      _showMessage(
        _t(
          'Theme preference selected.',
          'Napili na ang tema.',
        ),
      );
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _row(
    IconData icon,
    String label, {
    String? value,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final Widget? valueWidget = value == null
        ? null
        : Text(
            value,
            style: const TextStyle(
              color: C.grey,
              fontSize: 10,
            ),
          );

    return AppCard(
      borderColor: C.border,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 18,
      ),
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 16, color: C.navy),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: C.navy,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ?valueWidget,
          ?trailing,
          if (trailing == null)
            const Icon(
              Icons.chevron_right,
              size: 18,
              color: C.grey,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final languageValue = languageController.language;

    final themeValue = _theme == 'System default'
        ? _t('System default', 'Default ng system')
        : _theme == 'Light'
            ? _t('Light', 'Maliwanag')
            : _t('Dark', 'Madilim');

    return Scaffold(
      appBar: navyAppBar(
        context,
        _t('Settings', 'Mga Setting'),
        fallback: '/more',
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _row(
            Icons.lock_outline,
            _t('Change Password', 'Palitan ang Password'),
            onTap: _changePassword,
          ),
          _row(
            Icons.notifications_none,
            _t('Notifications', 'Mga Abiso'),
            trailing: Switch(
              value: _notifications,
              activeThumbColor: Colors.white,
              activeTrackColor: C.orange,
              onChanged: (v) {
                setState(() => _notifications = v);

                _showMessage(
                  v
                      ? _t(
                          'Notifications preference turned on.',
                          'Naka-on ang mga abiso.',
                        )
                      : _t(
                          'Notifications preference turned off.',
                          'Naka-off ang mga abiso.',
                        ),
                );
              },
            ),
          ),
          _row(
            Icons.language,
            _t('Language', 'Wika'),
            value: languageValue,
            onTap: _chooseLanguage,
          ),
          _row(
            Icons.contrast,
            _t('Theme', 'Tema'),
            value: themeValue,
            onTap: _chooseTheme,
          ),
          _row(
            Icons.delete_outline,
            _t('Clear Cache', 'Linisin ang Cache'),
            onTap: () => _showMessage(
              _t(
                'Cache clearing is not configured in this app yet.',
                'Hindi pa naka-configure ang paglilinis ng cache.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
