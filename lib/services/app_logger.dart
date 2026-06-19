import 'dart:io';

import 'package:path/path.dart' as p;

import 'path_service.dart';

class AppLogger {
  const AppLogger._();

  static const maxBytes = 1024 * 1024;
  static const maxFiles = 5;

  static String get directory {
    return p.join(p.dirname(PathService.configPath()), 'logs');
  }

  static String get logPath => p.join(directory, 'launcher.log');

  static void info(String message) => _write('INFO', message);

  static void warning(String message) => _write('WARN', message);

  static void error(String message) => _write('ERROR', message);

  static Future<void> openDirectory() async {
    Directory(directory).createSync(recursive: true);
    if (Platform.isWindows) {
      await Process.start('explorer', [directory]);
      return;
    }
    await Process.start(directory, const []);
  }

  static void _write(String level, String message) {
    try {
      final dir = Directory(directory)..createSync(recursive: true);
      final file = File(p.join(dir.path, 'launcher.log'));
      _rotateIfNeeded(file);
      final stamp = DateTime.now().toIso8601String();
      file.writeAsStringSync(
        '[$stamp] [$level] $message\n',
        mode: FileMode.append,
        flush: true,
      );
    } catch (_) {
      // Logging must never break launcher behavior.
    }
  }

  static void _rotateIfNeeded(File file) {
    if (!file.existsSync() || file.lengthSync() < maxBytes) return;

    for (var index = maxFiles; index >= 1; index--) {
      final current = File('$logPath.$index');
      final next = File('$logPath.${index + 1}');
      if (!current.existsSync()) continue;
      if (index == maxFiles) {
        current.deleteSync();
      } else {
        if (next.existsSync()) next.deleteSync();
        current.renameSync(next.path);
      }
    }

    final first = File('$logPath.1');
    if (first.existsSync()) first.deleteSync();
    file.renameSync(first.path);
  }
}
