import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';
import '../widgets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 2), () {
      if (mounted) context.go('/login');
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.navy,
      body: Stack(children: [
        Positioned.fill(child: CustomPaint(painter: _WavePainter())),
        Positioned(
          bottom: 90,
          left: 20,
          right: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
                5,
                (_) => const Icon(Icons.person,
                    size: 54, color: Color(0xFF041A3C))),
          ),
        ),
        SafeArea(
          child: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: const [
              LogoMark(size: 110),
              SizedBox(height: 24),
              Row(mainAxisSize: MainAxisSize.min, children: [
                Text('Liga ',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w800)),
                Text('Local',
                    style: TextStyle(
                        color: C.orange,
                        fontSize: 34,
                        fontWeight: FontWeight.w800)),
              ]),
              SizedBox(height: 12),
              Text('Barangay Sports\nFestival',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800)),
              SizedBox(height: 4),
              Text('Scheduling & Live Standing Board',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ]),
          ),
        ),
        const Positioned(
          bottom: 28,
          left: 0,
          right: 0,
          child: Text('— Play • Compete • Unite',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700)),
        ),
      ]),
    );
  }
}

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final wave = Path()
      ..moveTo(0, h * 0.78)
      ..quadraticBezierTo(w * 0.45, h * 0.68, w, h * 0.74)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(wave, Paint()..color = C.navy2);

    final line = Path()
      ..moveTo(0, h * 0.87)
      ..quadraticBezierTo(w * 0.5, h * 0.84, w, h * 0.96);
    canvas.drawPath(
      line,
      Paint()
        ..color = C.orange
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}