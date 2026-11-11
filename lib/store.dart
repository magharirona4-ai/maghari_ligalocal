import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'data.dart';
import 'dates.dart';

/// One live (or finished) match.
class LiveMatch {
  LiveMatch({
    required this.id,
    required this.sport,
    required this.title,
    required this.home,
    required this.away,
    required this.period,
    this.homeScore = 0,
    this.awayScore = 0,
    this.homeSets = 0,
    this.awaySets = 0,
    this.clock = '',
    this.isFinal = false,
    this.onHome = true,
    this.stats,
    this.ts = 0,
    this.division = 'men',
  });

  final String id, sport, title, home, away;
  int homeScore, awayScore;
  int homeSets, awaySets; // volleyball only
  String period, clock;
  bool isFinal;
  final bool onHome; // show in Home > Ongoing Matches?
  final List<(String, String, String)>? stats;
  final int ts; // creation order
  final String division; // 'men' or 'women'

  bool get _volleyball => sport == 'Volleyball';

  /// Volleyball: the period text also shows the sets won.
  String get periodText =>
      _volleyball ? '$period • Sets $homeSets - $awaySets' : period;

  String get status => isFinal
      ? 'Final'
      : (clock.isEmpty ? periodText : '$periodText • $clock');

  /// What the big numbers show. Volleyball: points in the current set,
  /// then the sets won once the match is final.
  int get homeShown => (_volleyball && isFinal) ? homeSets : homeScore;
  int get awayShown => (_volleyball && isFinal) ? awaySets : awayScore;
  String get score => '$homeShown - $awayShown';

  Map<String, dynamic> toMap() => {
        'sport': sport,
        'title': title,
        'home': home,
        'away': away,
        'homeScore': homeScore,
        'awayScore': awayScore,
        'homeSets': homeSets,
        'awaySets': awaySets,
        'period': period,
        'clock': clock,
        'isFinal': isFinal,
        'onHome': onHome,
        'ts': ts,
        'division': division,
        if (stats != null)
          'stats': [
            for (final s in stats!) {'l': s.$1, 'k': s.$2, 'r': s.$3}
          ],
      };

  factory LiveMatch.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    List<(String, String, String)>? stats;
    final raw = d['stats'];
    if (raw is List) {
      stats = [];
      for (final e in raw) {
        final m = e as Map;
        stats.add((m['l'] as String, m['k'] as String, m['r'] as String));
      }
    }
    return LiveMatch(
      id: doc.id,
      sport: d['sport'] as String? ?? 'Basketball',
      title: d['title'] as String? ?? '',
      home: d['home'] as String? ?? '',
      away: d['away'] as String? ?? '',
      homeScore: (d['homeScore'] as num?)?.toInt() ?? 0,
      awayScore: (d['awayScore'] as num?)?.toInt() ?? 0,
      homeSets: (d['homeSets'] as num?)?.toInt() ?? 0,
      awaySets: (d['awaySets'] as num?)?.toInt() ?? 0,
      period: d['period'] as String? ?? '',
      clock: d['clock'] as String? ?? '',
      isFinal: d['isFinal'] as bool? ?? false,
      onHome: d['onHome'] as bool? ?? true,
      stats: stats,
      ts: (d['ts'] as num?)?.toInt() ?? 0,
      division: (d['division'] as String?) == 'women' ? 'women' : 'men',
    );
  }
}

List<String> periodsFor(String sport) {
  switch (sport) {
    case 'Volleyball':
      return ['1st Set', '2nd Set', '3rd Set', '4th Set', '5th Set'];
    case 'Football':
      return ['1st Half', '2nd Half'];
    default:
      return ['1st Qtr', '2nd Qtr', '3rd Qtr', '4th Qtr'];
  }
}

List<int> incrementsFor(String sport) =>
    sport == 'Basketball' ? [1, 2, 3] : [1];

List<LiveMatch> _seedMatches() => [
      LiveMatch(
        id: '1',
        sport: 'Basketball',
        title: 'Basketball - Finals',
        home: 'Taytay United',
        away: 'Bgy. Maasin',
        homeScore: 62,
        awayScore: 58,
        period: '4th Qtr',
        clock: '02:34',
        onHome: false,
        ts: 1,
        stats: const [
          ('24/52', 'FG', '22/49'),
          ('6/18', '3PT', '5/15'),
          ('8/10', 'FT', '9/12'),
          ('32', 'REB', '28'),
          ('14', 'AST', '11'),
          ('8', 'TO', '10'),
        ],
      ),
      LiveMatch(
        id: '2',
        sport: 'Basketball',
        title: 'Basketball - Semi Finals',
        home: 'San Isidro',
        away: 'Poblacion',
        homeScore: 24,
        awayScore: 18,
        period: '2nd Qtr',
        ts: 2,
      ),
      LiveMatch(
        id: '3',
        sport: 'Volleyball',
        title: 'Volleyball - Finals',
        home: 'Taytay United',
        away: 'Bgy. Maasin',
        homeScore: 15,
        awayScore: 12,
        period: '1st Set',
        ts: 3,
      ),
    ];

int _now() => DateTime.now().millisecondsSinceEpoch;
int _tsOf(Map<String, dynamic> d) => (d['ts'] as num?)?.toInt() ?? 0;
int _n(Map<String, dynamic> d, String key) => (d[key] as num?)?.toInt() ?? 0;

Map<String, dynamic> _standingMap(Standing s) => {
      'w': s.w,
      'l': s.l,
      'pts': s.pts,
      'mw': s.mw,
      'ml': s.ml,
      'mpts': s.mpts,
      'ww': s.ww,
      'wl': s.wl,
      'wpts': s.wpts,
    };

/// Keeps the app in sync with Firebase (Firestore).
/// When the organizer changes something, every phone updates by itself.
class AppStore extends ChangeNotifier {
  final List<LiveMatch> matches = [];
  bool teamsLoaded = false; // true after the first answer from Firebase

  final List<StreamSubscription<dynamic>> _subs = [];
  bool _started = false;

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  void _onError(Object e) => debugPrint('Firestore error: $e');

  /// Called after login.
  void start() {
    if (_started) return;
    _started = true;

    _subs.add(_db.collection('teams').snapshots().listen((snap) {
      final items = [
        for (final d in snap.docs)
          (
            _tsOf(d.data()),
            Team(
              d.id,
              d.data()['name'] as String? ?? d.id,
              d.data()['barangay'] as String? ?? '',
              (d.data()['colorIndex'] as num?)?.toInt() ?? 0,
            )
          )
      ];
      items.sort((a, b) => a.$1.compareTo(b.$1));
      teams
        ..clear()
        ..addAll(items.map((e) => e.$2));
      teamsLoaded = true;
      notifyListeners();
    }, onError: _onError));

    _subs.add(_db.collection('standings').snapshots().listen((snap) {
      final items = [
        for (final d in snap.docs)
          Standing(
            d.id,
            _n(d.data(), 'w'),
            _n(d.data(), 'l'),
            _n(d.data(), 'pts'),
            mw: _n(d.data(), 'mw'),
            ml: _n(d.data(), 'ml'),
            mpts: _n(d.data(), 'mpts'),
            ww: _n(d.data(), 'ww'),
            wl: _n(d.data(), 'wl'),
            wpts: _n(d.data(), 'wpts'),
          )
      ];
      // Tiebreak: points, then wins, then fewer losses, then team id
      items.sort((a, b) {
        var c = b.pts.compareTo(a.pts);
        if (c != 0) return c;
        c = b.w.compareTo(a.w);
        if (c != 0) return c;
        c = a.l.compareTo(b.l);
        if (c != 0) return c;
        return a.teamId.compareTo(b.teamId);
      });
      standings
        ..clear()
        ..addAll(items);
      notifyListeners();
    }, onError: _onError));

    _subs.add(_db.collection('games').snapshots().listen((snap) {
      final items = [
        for (final d in snap.docs)
          (
            _tsOf(d.data()),
            Game(
              d.data()['sport'] as String? ?? '',
              d.data()['time'] as String? ?? '',
              d.data()['home'] as String? ?? '',
              d.data()['away'] as String? ?? '',
              id: d.id,
              date: d.data()['date'] as String? ?? '',
              division:
                  (d.data()['division'] as String?) == 'women' ? 'women' : 'men',
            )
          )
      ];
      items.sort((a, b) {
        final byDay = a.$2.dayKey.compareTo(b.$2.dayKey);
        if (byDay != 0) return byDay;
        final byTime = a.$2.minutes.compareTo(b.$2.minutes);
        if (byTime != 0) return byTime;
        return a.$1.compareTo(b.$1);
      });
      games
        ..clear()
        ..addAll(items.map((e) => e.$2));
      notifyListeners();
    }, onError: _onError));

    _subs.add(_db.collection('matches').snapshots().listen((snap) {
      final items = [for (final d in snap.docs) LiveMatch.fromDoc(d)];
      items.sort((a, b) => a.ts.compareTo(b.ts));
      matches
        ..clear()
        ..addAll(items);
      notifyListeners();
    }, onError: _onError));
  }

  /// Called after logout.
  void stop() {
    for (final s in _subs) {
      s.cancel();
    }
    _subs.clear();
    _started = false;
    teamsLoaded = false;
    teams.clear();
    standings.clear();
    games.clear();
    matches.clear();
    notifyListeners();
  }

  LiveMatch? matchById(String id) {
    for (final m in matches) {
      if (m.id == id) return m;
    }
    return null;
  }

  Future<void> _safe(Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      debugPrint('Firestore write failed: $e');
    }
  }

  // ---------------- Organizer actions ----------------

  void changeScore(LiveMatch m, {required bool home, required int by}) {
    if (m.isFinal) return;
    final current = home ? m.homeScore : m.awayScore;
    if (current + by < 0) return;
    _safe(() => _db.collection('matches').doc(m.id).update({
          home ? 'homeScore' : 'awayScore': FieldValue.increment(by),
        }));
  }

  void setPeriod(LiveMatch m, String p) {
    if (m.isFinal) return;
    _safe(() =>
        _db.collection('matches').doc(m.id).update({'period': p, 'clock': ''}));
  }

  /// Ends the match and updates Standings (win = 3 pts). Returns false if it failed.
  /// Volleyball: the winner is the team that won more sets.
  Future<bool> finishMatch(LiveMatch m) async {
    if (m.isFinal) return true;
    try {
      await _db.runTransaction((tx) async {
        final ref = _db.collection('matches').doc(m.id);
        final snap = await tx.get(ref);
        final d = snap.data();
        if (d == null || d['isFinal'] == true) return;
        var hs = (d['homeScore'] as num?)?.toInt() ?? 0;
        var aw = (d['awayScore'] as num?)?.toInt() ?? 0;
        final updates = <String, Object?>{'isFinal': true, 'clock': ''};
        if (d['sport'] == 'Volleyball') {
          var hSets = (d['homeSets'] as num?)?.toInt() ?? 0;
          var aSets = (d['awaySets'] as num?)?.toInt() ?? 0;
          // A set that was not ended yet counts for the team that is ahead.
          if (hs > aw) {
            hSets++;
          } else if (aw > hs) {
            aSets++;
          }
          updates['homeSets'] = hSets;
          updates['awaySets'] = aSets;
          hs = hSets;
          aw = aSets;
        }
        tx.update(ref, updates);
        if (hs != aw) {
          final homeWon = hs > aw;
          final winner = teamByName((homeWon ? d['home'] : d['away']) as String).id;
          final loser = teamByName((homeWon ? d['away'] : d['home']) as String).id;
          // Overall and the division of this match (men or women) both change.
          final women = d['division'] == 'women';
          final winKey = women ? 'ww' : 'mw';
          final loseKey = women ? 'wl' : 'ml';
          final ptsKey = women ? 'wpts' : 'mpts';
          tx.set(
            _db.collection('standings').doc(winner),
            {
              'w': FieldValue.increment(1),
              'pts': FieldValue.increment(3),
              winKey: FieldValue.increment(1),
              ptsKey: FieldValue.increment(3),
            },
            SetOptions(merge: true),
          );
          tx.set(
            _db.collection('standings').doc(loser),
            {
              'l': FieldValue.increment(1),
              loseKey: FieldValue.increment(1),
            },
            SetOptions(merge: true),
          );
        }
      });
      return true;
    } catch (e) {
      debugPrint('finishMatch failed: $e');
      return false;
    }
  }

  /// Volleyball: ends the current set. The team with more points wins the set,
  /// the points go back to 0 and the next set starts.
  /// Returns null when OK, or a message to show.
  Future<String?> endSet(LiveMatch m) async {
    if (m.isFinal || m.sport != 'Volleyball') return null;
    String? problem;
    try {
      await _db.runTransaction((tx) async {
        final ref = _db.collection('matches').doc(m.id);
        final snap = await tx.get(ref);
        final d = snap.data();
        if (d == null || d['isFinal'] == true) return;
        final hs = (d['homeScore'] as num?)?.toInt() ?? 0;
        final aw = (d['awayScore'] as num?)?.toInt() ?? 0;
        if (hs == aw) {
          problem = 'The set is tied. Add points first.';
          return;
        }
        final periods = periodsFor('Volleyball');
        final idx = periods.indexOf((d['period'] as String?) ?? '');
        final next =
            (idx >= 0 && idx + 1 < periods.length) ? periods[idx + 1] : periods.last;
        tx.update(ref, {
          'homeSets': FieldValue.increment(hs > aw ? 1 : 0),
          'awaySets': FieldValue.increment(aw > hs ? 1 : 0),
          'homeScore': 0,
          'awayScore': 0,
          'period': next,
          'clock': '',
        });
      });
      return problem;
    } catch (e) {
      debugPrint('endSet failed: $e');
      return 'Could not end the set. Check your internet and try again.';
    }
  }

  /// Moves a scheduled game to live matches (0 - 0).
  void startGame(Game g) {
    if (g.id.isEmpty) return;
    _safe(() async {
      final batch = _db.batch();
      batch.delete(_db.collection('games').doc(g.id));
      final ref = _db.collection('matches').doc();
      batch.set(
        ref,
        LiveMatch(
          id: ref.id,
          sport: g.sport,
          title: '${g.sport} - ${divisionLabel(g.division)}',
          home: g.home,
          away: g.away,
          period: periodsFor(g.sport).first,
          ts: _now(),
          division: g.division,
        ).toMap(),
      );
      await batch.commit();
    });
  }

  void addGame(Game g) {
    _safe(() => _db.collection('games').add({
          'sport': g.sport,
          'time': g.time,
          'home': g.home,
          'away': g.away,
          'date': g.dayKey,
          'division': g.division,
          'ts': _now(),
        }));
  }

  /// Returns false if the name is empty or already used.
  bool addTeam(String name, String barangay) {
    final n = name.trim();
    if (n.isEmpty) return false;
    if (teams.any((t) => t.name.toLowerCase() == n.toLowerCase())) return false;
    var id = n.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
    while (teams.any((t) => t.id == id)) {
      id = '$id-x';
    }
    final b = barangay.trim();
    final fullBarangay = b.isEmpty
        ? 'Barangay $n'
        : (b.toLowerCase().startsWith('barangay') ? b : 'Barangay $b');
    final colorIndex = 6 + teams.length % 5;
    _safe(() async {
      final batch = _db.batch();
      batch.set(_db.collection('teams').doc(id), {
        'name': n,
        'barangay': fullBarangay,
        'colorIndex': colorIndex,
        'ts': _now(),
      });
      batch.set(_db.collection('standings').doc(id), {'w': 0, 'l': 0, 'pts': 0});
      await batch.commit();
    });
    return true;
  }

  /// First-time setup: copies the sample teams, standings, games and matches.
  Future<bool> seedSampleData() async {
    try {
      final batch = _db.batch();
      for (var i = 0; i < seedTeams.length; i++) {
        final t = seedTeams[i];
        batch.set(_db.collection('teams').doc(t.id), {
          'name': t.name,
          'barangay': t.barangay,
          'colorIndex': t.colorIndex,
          'ts': i + 1,
        });
      }
      for (final s in seedStandings) {
        batch.set(_db.collection('standings').doc(s.teamId), _standingMap(s));
      }
      for (var i = 0; i < seedGames.length; i++) {
        final g = seedGames[i];
        batch.set(_db.collection('games').doc(), {
          'sport': g.sport,
          'time': g.time,
          'home': g.home,
          'away': g.away,
          'date': dateKey(dayFromToday(0)),
          'division': g.division,
          'ts': i + 1,
        });
      }
      for (final m in _seedMatches()) {
        batch.set(_db.collection('matches').doc(m.id), m.toMap());
      }
      await batch.commit();
      return true;
    } catch (e) {
      debugPrint('seedSampleData failed: $e');
      return false;
    }
  }

  /// For a database that already has teams: fills the Men's and Women's
  /// standings with sample results. The Overall standings become the sample totals.
  Future<bool> seedDivisionStandings() async {
    try {
      final batch = _db.batch();
      for (final s in seedStandings) {
        if (!teams.any((t) => t.id == s.teamId)) continue;
        batch.set(_db.collection('standings').doc(s.teamId), _standingMap(s),
            SetOptions(merge: true));
      }
      await batch.commit();
      return true;
    } catch (e) {
      debugPrint('seedDivisionStandings failed: $e');
      return false;
    }
  }
}

final store = AppStore();
