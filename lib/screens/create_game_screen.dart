
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data.dart';
import '../dates.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets.dart';

/// Organizer: add a new game to the schedule.
class CreateGameScreen extends StatefulWidget {
  const CreateGameScreen({super.key});

  @override
  State<CreateGameScreen> createState() => _CreateGameScreenState();
}

class _CreateGameScreenState extends State<CreateGameScreen> {
  final List<String> _sports = [
    'Basketball',
    'Volleyball',
    'Football',
    'Badminton',
    'Sepak Takraw',
    'Table Tennis',
    'Lawn Tennis',
    'Chess',
    'Athletics',
    'Swimming',
    'Darts',
    'Billiards',
  ];

  String _selectedSport = 'Basketball';
  int _day = 0;
  int _division = 0;
  Team? _home;
  Team? _away;
  TimeOfDay? _time;

  Future<void> _addSport() async {
    final sport = await showDialog<String>(
      context: context,
      builder: (dialogContext) => const _AddSportDialog(),
    );

    if (!mounted || sport == null) return;

    final existing = _sports.indexWhere(
      (s) => s.toLowerCase() == sport.toLowerCase(),
    );

    setState(() {
      if (existing >= 0) {
        _selectedSport = _sports[existing];
      } else {
        _sports.add(sport);
        _selectedSport = sport;
      }
    });
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );

    if (t != null && mounted) {
      setState(() => _time = t);
    }
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  void _save() {
    if (_home == null || _away == null || _time == null) {
      _message('Choose both teams and a time.');
      return;
    }

    if (_home!.id == _away!.id) {
      _message('Pick two different teams.');
      return;
    }

    store.addGame(Game(
      _selectedSport,
      fmtTime(_time!),
      _home!.name,
      _away!.name,
      date: dateKey(dayFromToday(_day)),
      division: _division == 1 ? 'women' : 'men',
    ));

    _message('Game added to the schedule.');
    context.pop();
  }

  Widget _sectionTitle(String label) => Text(
        label,
        style: const TextStyle(
          color: C.navy,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      );

  Widget _teamPicker(
    String label,
    Team? selected,
    ValueChanged<Team> onPick,
  ) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(label),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in teams)
                ChoiceChip(
                  label: Text(t.name),
                  selected: selected?.id == t.id,
                  selectedColor: C.orange,
                  labelStyle: TextStyle(
                    color: selected?.id == t.id
                        ? Colors.white
                        : C.navy,
                    fontSize: 12,
                  ),
                  onSelected: (_) => onPick(t),
                ),
            ],
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: navyAppBar(
        context,
        'Create Game',
        fallback: '/organizer',
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle('Sport'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: C.navy, width: 1.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final sport in _sports)
                  ChoiceChip(
                    label: Text(sport),
                    selected: _selectedSport == sport,
                    selectedColor: C.orange,
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: _selectedSport == sport
                          ? C.orange
                          : C.border,
                    ),
                    labelStyle: TextStyle(
                      color: _selectedSport == sport
                          ? Colors.white
                          : C.navy,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (_) {
                      setState(() => _selectedSport = sport);
                    },
                  ),
                ActionChip(
                  avatar: const Icon(
                    Icons.add,
                    color: C.orange,
                    size: 18,
                  ),
                  label: const Text('Add Sport'),
                  backgroundColor: const Color(0xFFFFF3E8),
                  side: const BorderSide(color: C.orange),
                  labelStyle: const TextStyle(
                    color: C.orange,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                  onPressed: _addSport,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _sectionTitle('Division'),
          const SizedBox(height: 8),
          PillTabs(
            labels: const ["Men's", "Women's"],
            selected: _division,
            onChanged: (i) => setState(() => _division = i),
          ),
          const SizedBox(height: 20),
          _sectionTitle('Date'),
          const SizedBox(height: 8),
          PillTabs(
            labels: [for (var i = 0; i < 4; i++) dayLabel(i)],
            selected: _day,
            onChanged: (i) => setState(() => _day = i),
          ),
          const SizedBox(height: 20),
          _teamPicker(
            'Home team',
            _home,
            (t) => setState(() => _home = t),
          ),
          const SizedBox(height: 20),
          _teamPicker(
            'Away team',
            _away,
            (t) => setState(() => _away = t),
          ),
          const SizedBox(height: 20),
          _sectionTitle('Time'),
          const SizedBox(height: 8),
          SizedBox(
            height: 46,
            child: OutlinedButton.icon(
              onPressed: _pickTime,
              icon: const Icon(
                Icons.access_time,
                size: 18,
                color: C.navy,
              ),
              label: Text(
                _time == null ? 'Choose time' : fmtTime(_time!),
                style: const TextStyle(
                  color: C.navy,
                  fontSize: 13,
                ),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: C.navy),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          PrimaryButton('Save Game', onPressed: _save),
        ],
      ),
    );
  }
}

/// Separate dialog widget manages its own TextEditingController.
class _AddSportDialog extends StatefulWidget {
  const _AddSportDialog();

  @override
  State<_AddSportDialog> createState() => _AddSportDialogState();
}

class _AddSportDialogState extends State<_AddSportDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _add() {
    final value = _controller.text.trim();

    if (value.isNotEmpty) {
      Navigator.of(context).pop(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Add Other Sport',
        style: TextStyle(
          color: C.navy,
          fontWeight: FontWeight.w800,
        ),
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(
          hintText: 'Enter sport name',
          border: OutlineInputBorder(),
        ),
        onSubmitted: (_) => _add(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _add,
          child: const Text('Add Sport'),
        ),
      ],
    );
  }
}
