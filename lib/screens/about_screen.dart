import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';
import '../widgets.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Widget _circle(IconData icon) => Container(
        width: 46,
        height: 46,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: C.border),
        ),
        child: Icon(icon, size: 18, color: C.navy),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(children: [
          Positioned(
            top: 4,
            left: 4,
            child: IconButton(
              icon: const Icon(Icons.chevron_left, color: C.navy, size: 28),
              onPressed: () => context.canPop() ? context.pop() : context.go('/more'),
            ),
          ),
          Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const LogoMark(size: 64),
              const SizedBox(height: 12),
              const Text('LigaLocal',
                  style: TextStyle(
                      color: C.navy, fontSize: 26, fontWeight: FontWeight.w800)),
              const SizedBox(height: 18),
              const Text('Barangay Sports Festival\nScheduling & Live Standing Board',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: C.navy, fontSize: 11, height: 1.5)),
              const SizedBox(height: 18),
              const Text('Version 1.0.0',
                  style: TextStyle(color: C.grey, fontSize: 10)),
              const SizedBox(height: 22),
              Row(mainAxisSize: MainAxisSize.min, children: [
                _circle(Icons.facebook),
                _circle(Icons.camera_alt_outlined),
                _circle(Icons.play_arrow),
                _circle(Icons.mail_outline),
              ]),
              const SizedBox(height: 24),
              const Text('Play • Compete • Unite',
                  style: TextStyle(
                      color: C.orange, fontSize: 11, fontWeight: FontWeight.w700)),
            ]),
          ),
        ]),
      ),
    );
  }
}
