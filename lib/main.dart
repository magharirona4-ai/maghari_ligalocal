
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'router.dart';
import 'theme.dart';
import 'language_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const LigaLocalApp());
}

class LigaLocalApp extends StatelessWidget {
  const LigaLocalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: languageController,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'LigaLocal',
          debugShowCheckedModeBanner: false,
          routerConfig: router,
          theme: buildTheme(),
        );
      },
    );
  }
}
