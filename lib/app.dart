import 'package:flutter/material.dart';

import 'constants.dart';
import 'screens/launcher_home.dart';

class Vic3LauncherApp extends StatelessWidget {
  const Vic3LauncherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff2d6a63),
          brightness: Brightness.dark,
        ),
        listTileTheme: const ListTileThemeData(dense: true),
        scaffoldBackgroundColor: const Color(0xff071314),
      ),
      home: const LauncherHome(),
    );
  }
}
