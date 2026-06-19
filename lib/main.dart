import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:window_manager/window_manager.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPaintBaselinesEnabled = false;
  debugPaintSizeEnabled = false;
  await windowManager.ensureInitialized();
  const windowOptions = WindowOptions(
    size: Size(760, 920),
    minimumSize: Size(700, 820),
    center: true,
    titleBarStyle: TitleBarStyle.hidden,
    backgroundColor: Color(0xff071314),
  );
  runApp(const Vic3LauncherApp());
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
}
