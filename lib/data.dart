import 'package:flutter/material.dart';
import 'dates.dart';

// The real data now lives in Firebase (Firestore) and is copied into the
// lists below by store.dart. The "seed" lists are only used by the button
// "Load sample data" in the Organizer Panel (first time only).

const userName = 'Rona';
const userFullName = 'Rona Maghari';
const userEmail = 'rona.maghari@gmail.com';

/// Team colors. A team saves only a number (colorIndex) in Firebase.
const teamPalette = <Color>[
  Color(0xFFC0392B), // 0
  Color(0xFFE5484D), // 1
  Color(0xFF2EA043), // 2
  Color(0xFF8E44AD), // 3
  Color(0xFFF1C40F), // 4
  Color(0xFF2F7DE1), // 5
  Color(0xFFE67E22), // 6
  Color(0xFF16A085), // 7
  Color(0xFFD35400), // 8
  Color(0xFF7F8C8D), // 9 (grey, used when a team is not found)
  Color(0xFFC2185B), // 10
];

class Team {
  Team(this.id, this.name, this.barangay, this.colorIndex)
      : color = teamPalette[colorIndex % teamPalette.length];
  final String id, name, barangay;
  final int colorIndex;
  final Color color;
}

/// w, l, pts = Overall. mw, ml, mpts = Men's. ww, wl, wpts = Women's.
class Standing {
  const Standing(this.teamId, this.w, this.l, this.pts,
      {this.mw = 0,
      this.ml = 0,
      this.mpts = 0,
      this.ww = 0,
      this.wl = 0,
      this.wpts = 0});
  final String teamId;
  final int w, l, pts, mw, ml, mpts, ww, wl, wpts;

  // tab: 0 = Overall, 1 = Men's, 2 = Women's
  int winsFor(int tab) => tab == 1 ? mw : (tab == 2 ? ww : w);
  int lossesFor(int tab) => tab == 1 ? ml : (tab == 2 ? wl : l);
  int ptsFor(int tab) => tab == 1 ? mpts : (tab == 2 ? wpts : pts);
}

/// 'men' -> Men's, 'women' -> Women's
String divisionLabel(String division) => division == 'women' ? 'Women’s' : 'Men’s';

class Game {
  const Game(this.sport, this.time, this.home, this.away,
      {this.id = '', this.date = '', this.division = 'men'});
  final String sport, time, home, away;
  final String id; // Firestore document id
  final String date; // "2026-11-08" (empty = today, for older games)
  final String division; // 'men' or 'women'
  String get venue =>
      '${divisionLabel(division)} • Court 1 • Barangay Sports Complex';

  /// The day this game is on.
  String get dayKey => date.isEmpty ? dateKey(dayFromToday(0)) : date;

  /// Minutes since midnight, to sort games in a day.
  int get minutes => parseTimeMinutes(time);
}

// ---- Live lists (filled from Firebase by store.dart) ----
final List<Team> teams = [];
final List<Standing> standings = [];
final List<Game> games = [];

Team teamById(String id) {
  for (final t in teams) {
    if (t.id == id) return t;
  }
  return Team(id, id, '', 9);
}

Team teamByName(String name) {
  for (final t in teams) {
    if (t.name == name) return t;
  }
  return Team(name, name, '', 9);
}

Standing standingOf(String id) {
  for (final s in standings) {
    if (s.teamId == id) return s;
  }
  return Standing(id, 0, 0, 0);
}

// ---- Sample data for "Load sample data" (same as your Figma) ----
final List<Team> seedTeams = [
  Team('taytay-united', 'Taytay United', 'Barangay Taytay', 0),
  Team('san-isidro', 'San Isidro', 'Barangay San Isidro', 1),
  Team('poblacion', 'Poblacion', 'Barangay Poblacion', 2),
  Team('bgy-maasin', 'Bgy. Maasin', 'Barangay Maasin', 3),
  Team('balabac', 'Balabac', 'Barangay Balabac', 4),
  Team('san-rafael', 'San Rafael', 'Barangay San Rafael', 5),
];

const seedStandings = <Standing>[
  Standing('taytay-united', 6, 1, 18, mw: 4, ml: 0, mpts: 12, ww: 2, wl: 1, wpts: 6),
  Standing('san-isidro', 5, 2, 15, mw: 2, ml: 1, mpts: 6, ww: 3, wl: 1, wpts: 9),
  Standing('poblacion', 4, 3, 12, mw: 3, ml: 1, mpts: 9, ww: 1, wl: 2, wpts: 3),
  Standing('bgy-maasin', 3, 4, 9, mw: 1, ml: 3, mpts: 3, ww: 2, wl: 1, wpts: 6),
  Standing('balabac', 2, 5, 6, mw: 1, ml: 2, mpts: 3, ww: 1, wl: 3, wpts: 3),
  Standing('san-rafael', 1, 6, 3, mw: 0, ml: 3, mpts: 0, ww: 1, wl: 3, wpts: 3),
];

const seedGames = <Game>[
  Game('Basketball', '09:00 AM', 'San Isidro', 'Poblacion'),
  Game('Basketball', '10:30 AM', 'Taytay United', 'Bgy. Maasin', division: 'women'),
  Game('Volleyball', '01:00 PM', 'Taytay United', 'Poblacion', division: 'women'),
  Game('Football', '03:00 PM', 'San Isidro', 'Bgy. Maasin'),
];

class MyTeam {
  const MyTeam(this.teamId, this.sport, this.color);
  final String teamId, sport;
  final Color color;
}

const myTeams = <MyTeam>[
  MyTeam('taytay-united', 'Basketball', Color(0xFF062451)),
  MyTeam('poblacion', 'Volleyball', Color(0xFFA6202B)),
  MyTeam('bgy-maasin', 'Basketball', Color(0xFF1E7A3C)),
  MyTeam('san-isidro', 'Volleyball', Color(0xFFC27A1A)),
];
