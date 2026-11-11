import 'package:flutter/material.dart';

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// Today + offset days, at midnight.
DateTime dayFromToday(int offset) {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day + offset);
}

/// "2026-11-08" - this is what is saved in Firebase.
String dateKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// Tab label: Today, Tomorrow, then "Nov 10", "Nov 11"...
String dayLabel(int offset) {
  if (offset == 0) return 'Today';
  if (offset == 1) return 'Tomorrow';
  final d = dayFromToday(offset);
  return '${_months[d.month - 1]} ${d.day}';
}

/// Turns a saved date ("2026-11-08") into Today / Tomorrow / "Nov 8".
String labelForKey(String key) {
  if (key == dateKey(dayFromToday(0))) return 'Today';
  if (key == dateKey(dayFromToday(1))) return 'Tomorrow';
  final parts = key.split('-');
  if (parts.length != 3) return key;
  final m = int.tryParse(parts[1]);
  final day = int.tryParse(parts[2]);
  if (m == null || day == null || m < 1 || m > 12) return key;
  return '${_months[m - 1]} $day';
}

/// Always "09:00 AM" style, whatever the phone's settings are.
String fmtTime(TimeOfDay t) {
  final h12 = t.hour % 12 == 0 ? 12 : t.hour % 12;
  final suffix = t.hour < 12 ? 'AM' : 'PM';
  return '${h12.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')} $suffix';
}

/// "01:30 PM" -> 810 (minutes since midnight). Used to sort games.
int parseTimeMinutes(String s) {
  final m = RegExp(r'^\s*(\d{1,2}):(\d{2})\s*([AaPp][Mm])?\s*$').firstMatch(s);
  if (m == null) return 0;
  var h = int.parse(m.group(1)!);
  final min = int.parse(m.group(2)!);
  final ap = m.group(3);
  if (ap != null) {
    h = h % 12;
    if (ap.toLowerCase() == 'pm') h += 12;
  }
  return h * 60 + min;
}