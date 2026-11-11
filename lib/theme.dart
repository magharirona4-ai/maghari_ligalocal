import 'package:flutter/material.dart';

/// All colors from your Figma design in one place.
class C {
  static const navy = Color(0xFF062451);
  static const navy2 = Color(0xFF0B3466); // live scoreboard / team banner
  static const orange = Color(0xFFFF7A0F);
  static const bg = Color(0xFFF4F7FC);
  static const grey = Color(0xFF5B6B8C);
  static const border = Color(0xFFD5DEEE);
  static const green = Color(0xFF1E8E4E);
  static const red = Color(0xFFE5484D);
}

ThemeData buildTheme() => ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: C.bg,
      colorScheme: ColorScheme.fromSeed(seedColor: C.orange, primary: C.orange),
    );
