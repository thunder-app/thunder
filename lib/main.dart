import 'package:flutter/material.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:thunder/thunder/thunder.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load up environment variables
  await dotenv.load(fileName: ".env");

  runApp(const ThunderApp());
}

class ThunderApp extends StatelessWidget {
  const ThunderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thunder',
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.dark,
      home: const Thunder(),
    );
  }
}
