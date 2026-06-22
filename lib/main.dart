import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:window_manager/window_manager.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPaintBaselinesEnabled = false;
  debugPaintSizeEnabled = false;
  await windowManager.ensureInitialized();
  const portraitWindowSize = Size(525, 925);
  const windowOptions = WindowOptions(
    size: portraitWindowSize,
    minimumSize: portraitWindowSize,
    maximumSize: portraitWindowSize,
    center: true,
    titleBarStyle: TitleBarStyle.hidden,
    backgroundColor: Color(0xff071314),
  );
  runApp(const Vic3LauncherApp());
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setResizable(false);
    await windowManager.show();
    await windowManager.focus();
  });
}
