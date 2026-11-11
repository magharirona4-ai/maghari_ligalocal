import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'theme.dart';

/// Navy bottom bar: Home / Schedule / Standing / More
class NavShell extends StatelessWidget {
  const NavShell({super.key, required this.shell});
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: C.navy,
        selectedItemColor: C.orange,
        unselectedItemColor: Colors.white,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        currentIndex: shell.currentIndex,
        onTap: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Schedule'),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: 'Standing'),
          BottomNavigationBarItem(icon: Icon(Icons.more_vert), label: 'More'),
        ],
      ),
    );
  }
}
