import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../constants.dart';
import '../models.dart';
import 'json_service.dart';

class PathService {
  static String configPath() {
    final appData = Platform.environment['APPDATA'];
    if (appData != null && appData.isNotEmpty) {
      return p.join(appData, 'Vic3ModLauncher', 'config.json');
    }
    return p.join(Directory.current.path, 'vic3_launcher_config.json');
  }

  static String detectUserDataPath() {
    final home =
        Platform.environment['USERPROFILE'] ??
        Platform.environment['HOME'] ??
        '';
    final oneDrive =
        Platform.environment['OneDrive'] ??
        Platform.environment['OneDriveConsumer'] ??
        '';
    final candidates = [
      p.join(home, 'Documents', 'Paradox Interactive', gameName),
      p.join(home, 'OneDrive', 'Documents', 'Paradox Interactive', gameName),
      p.join(home, 'OneDrive', 'Dokumen', 'Paradox Interactive', gameName),
      if (oneDrive.isNotEmpty)
        p.join(oneDrive, 'Documents', 'Paradox Interactive', gameName),
      if (oneDrive.isNotEmpty)
        p.join(oneDrive, 'Dokumen', 'Paradox Interactive', gameName),
    ];
    for (final candidate in candidates) {
      if (Directory(candidate).existsSync()) return candidate;
    }
    return candidates.first;
  }

  static String detectGameRoot() {
    final candidates = [
      r'D:\Victoria 3',
      r'D:\Game\Victoria 3',
      r'D:\Games\Victoria 3',
      r'D:\Victoria3',
      r'D:\Paradox\Victoria 3',
    ];
    for (final candidate in candidates) {
      if (findGameExe(candidate).isNotEmpty) return candidate;
    }
    return '';
  }

  static Future<String> detectGameRootFromDesktopShortcut() async {
    if (!Platform.isWindows) return '';
    const script = r'''
$ErrorActionPreference = 'SilentlyContinue'
$shell = New-Object -ComObject WScript.Shell
$dirs = @([Environment]::GetFolderPath('Desktop'), [Environment]::GetFolderPath('CommonDesktopDirectory')) | Where-Object { $_ -and (Test-Path -LiteralPath $_) }
$items = foreach ($dir in $dirs) {
  Get-ChildItem -LiteralPath $dir -Filter '*.lnk' | Where-Object { $_.BaseName -match 'Victoria\s*3|Victoria3' } | ForEach-Object {
    $s = $shell.CreateShortcut($_.FullName)
    [pscustomobject]@{ target = $s.TargetPath; working = $s.WorkingDirectory; shortcut = $_.FullName }
  }
}
$items | ConvertTo-Json -Compress
''';
    try {
      final result = await Process.run('powershell', [
        '-NoProfile',
        '-ExecutionPolicy',
        'Bypass',
        '-Command',
        script,
      ]);
      if (result.exitCode != 0 || result.stdout.toString().trim().isEmpty) {
        return '';
      }
      final decoded = jsonDecode(result.stdout.toString());
      final rows = decoded is List ? decoded : [decoded];
      for (final row in rows) {
        final target = row['target']?.toString() ?? '';
        if (target.toLowerCase().endsWith('victoria3.exe')) {
          final root = rootFromExe(target);
          if (root.isNotEmpty) return root;
        }
      }
    } catch (_) {
      return '';
    }
    return '';
  }

  static String rootFromExe(String exePath) {
    final parent = p.dirname(exePath);
    if (p.basename(parent).toLowerCase() == 'binaries') {
      return p.dirname(parent);
    }
    return parent;
  }

  static String findGameExe(String gameRoot) {
    if (gameRoot.isEmpty) return '';
    final candidates = [
      p.join(gameRoot, 'binaries', 'victoria3.exe'),
      p.join(gameRoot, 'victoria3.exe'),
      p.join(gameRoot, 'game', 'victoria3.exe'),
    ];
    for (final candidate in candidates) {
      if (File(candidate).existsSync()) return candidate;
    }
    return '';
  }

  static bool isValidGameRoot(String gameRoot) {
    return findGameExe(gameRoot).isNotEmpty;
  }

  static bool isLikelyVictoriaUserData(String userDataPath) {
    if (userDataPath.trim().isEmpty) return false;
    final normalized = normalizePath(p.normalize(userDataPath)).toLowerCase();
    final hasExpectedName =
        p.basename(userDataPath).toLowerCase() == 'victoria 3';
    final hasParadoxParent = normalized.contains('/paradox interactive/');
    final hasContentLoad = File(
      p.join(userDataPath, 'content_load.json'),
    ).existsSync();
    final hasModFolder = Directory(p.join(userDataPath, 'mod')).existsSync();
    return (hasExpectedName && hasParadoxParent) ||
        hasContentLoad ||
        hasModFolder;
  }

  static String detectGameVersion(String gameRoot) {
    final paths = [
      p.join(gameRoot, 'launcher', 'launcher-settings.json'),
      p.join(gameRoot, 'launcher-settings.json'),
      p.join(gameRoot, 'game', 'launcher-settings.json'),
    ];
    for (final path in paths) {
      final data = readJsonMap(path);
      for (final key in ['rawVersion', 'version', 'gameVersion']) {
        final value = data[key]?.toString() ?? '';
        final parsed = parseVersion(value);
        if (parsed.isNotEmpty) return parsed;
      }
    }

    for (final fileName in ['caligula_branch.txt', 'clausewitz_branch.txt']) {
      final file = File(p.join(gameRoot, fileName));
      if (!file.existsSync()) continue;
      final parsed = parseVersion(file.readAsStringSync());
      if (parsed.isNotEmpty) return parsed;
    }

    final root = Directory(gameRoot);
    if (root.existsSync()) {
      for (final entry in root.listSync().whereType<File>()) {
        final parsed = parseVersion(p.basename(entry.path));
        if (parsed.isNotEmpty) return parsed;
      }
    }
    return '';
  }

  static String parseVersion(String value) {
    final match = RegExp(r'(\d+\.\d+(?:\.\d+)?)').firstMatch(value);
    return match?.group(1) ?? '';
  }

  static VersionStatus versionCompatible(
    String gameVersion,
    String supportedVersion,
  ) {
    if (gameVersion.isEmpty || supportedVersion.trim().isEmpty) {
      return VersionStatus.unknown;
    }
    final supported = supportedVersion.trim();
    if (supported == '*') return VersionStatus.ok;
    final gameParts = gameVersion.split('.');
    final supportedParts = supported.split('.');
    if (supportedParts.contains('*')) {
      for (var i = 0; i < supportedParts.length && i < gameParts.length; i++) {
        if (supportedParts[i] == '*') return VersionStatus.ok;
        if (supportedParts[i] != gameParts[i]) return VersionStatus.warning;
      }
      return VersionStatus.ok;
    }
    return gameVersion.startsWith(supported) ||
            supported.startsWith(gameVersion)
        ? VersionStatus.ok
        : VersionStatus.warning;
  }

  static String wildcardVersion(String gameVersion) {
    final parts = gameVersion.split('.');
    if (parts.length >= 2) return '${parts[0]}.${parts[1]}.*';
    return '*';
  }

  static String resolveContentPath(
    String rawPath,
    String basePath,
    String userDataPath,
  ) {
    if (rawPath.isEmpty) return '';
    final normalized = rawPath
        .replaceAll('/', p.separator)
        .replaceAll('\\', p.separator);
    if (p.isAbsolute(normalized)) return p.normalize(normalized);
    if (rawPath.replaceAll('\\', '/').startsWith('mod/')) {
      return p.normalize(p.join(userDataPath, normalized));
    }
    return p.normalize(p.join(basePath, normalized));
  }

  static String relativeDlcRef(String path, String gameRoot) {
    for (final base in [p.join(gameRoot, 'game'), gameRoot]) {
      if (base.isNotEmpty && isUnder(path, base)) {
        return normalizePath(p.relative(path, from: base));
      }
    }
    return normalizePath(path);
  }

  static String modRefForFile(String modFile) => 'mod/${p.basename(modFile)}';

  static String safeName(String value) {
    final cleaned = value
        .replaceAll(RegExp(r'[^A-Za-z0-9._ -]+'), '_')
        .trim()
        .replaceAll(RegExp(r'^[ ._]+|[ ._]+$'), '');
    return cleaned.isEmpty ? 'imported_mod' : cleaned;
  }

  static String uniquePath(String path) {
    if (!File(path).existsSync() && !Directory(path).existsSync()) return path;
    final dir = p.dirname(path);
    final name = p.basenameWithoutExtension(path);
    final ext = p.extension(path);
    var index = 2;
    while (true) {
      final candidate = p.join(dir, '${name}_$index$ext');
      if (!File(candidate).existsSync() && !Directory(candidate).existsSync()) {
        return candidate;
      }
      index += 1;
    }
  }

  static String normalizePath(String value) => value.replaceAll('\\', '/');

  static bool samePath(String a, String b) {
    return p.normalize(a).toLowerCase() == p.normalize(b).toLowerCase();
  }

  static bool isUnder(String child, String parent) {
    if (child.isEmpty || parent.isEmpty) return false;
    final rel = p.relative(p.normalize(child), from: p.normalize(parent));
    return rel == '.' || (!rel.startsWith('..') && !p.isAbsolute(rel));
  }
}
