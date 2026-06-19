import 'dart:io';

import 'package:path/path.dart' as p;

import '../models.dart';
import 'json_service.dart';
import 'launcher_config.dart';
import 'path_service.dart';

class DiagnosticService {
  const DiagnosticService();

  DiagnosticReport run({
    required LauncherConfig config,
    required Map<String, ModInfo> knownMods,
    required String gameVersion,
  }) {
    final debugLog = File(p.join(config.userDataPath, 'logs', 'debug.log'));
    final errorLog = File(p.join(config.userDataPath, 'logs', 'error.log'));
    final debugText = _readText(debugLog);
    final errorText = _readText(errorLog);
    final entries = _contentLoadEntries(config.contentLoadPath);

    final modChecks = [
      for (final entry in entries) _checkMod(entry, knownMods, debugText),
    ];

    return DiagnosticReport(
      generatedAt: DateTime.now(),
      gameRoot: config.gameRoot,
      userDataPath: config.userDataPath,
      gameVersion: gameVersion,
      contentLoadPath: config.contentLoadPath,
      contentLoadExists: File(config.contentLoadPath).existsSync(),
      debugLogPath: debugLog.path,
      debugLogModified: debugLog.existsSync()
          ? debugLog.lastModifiedSync()
          : null,
      errorLogPath: errorLog.path,
      errorLogModified: errorLog.existsSync()
          ? errorLog.lastModifiedSync()
          : null,
      modChecks: modChecks,
      debugFindings: _interestingLines(debugText, [
        'Mod:',
        'Mounted Data:',
        'Mod metadata',
        'No subdirs',
        'successfully matched game version',
        'does not match game version',
        'content_load',
      ], limit: 18),
      errorFindings: _interestingLines(errorText, [
        'Mod metadata',
        'No subdirs',
        'Failed to open',
        'Failed to read',
        'Script system error',
        'Could not find',
      ], limit: 18),
    );
  }

  List<String> _contentLoadEntries(String path) {
    final json = readJsonMap(path);
    final ordered = json['orderedListMods'];
    final enabled = json['enabledMods'];
    final source = ordered is List && ordered.isNotEmpty
        ? ordered
        : enabled is List
        ? enabled
        : const [];
    return [
      for (final item in source)
        if (_pathValue(item).trim().isNotEmpty) _pathValue(item),
    ];
  }

  DiagnosticModCheck _checkMod(
    String contentLoadPath,
    Map<String, ModInfo> knownMods,
    String debugText,
  ) {
    final normalized = PathService.normalizePath(contentLoadPath);
    final pathOnDisk = normalized.replaceAll('/', p.separator);
    final folder = Directory(pathOnDisk);
    final metadata = File(p.join(pathOnDisk, '.metadata', 'metadata.json'));
    final descriptor = File(p.join(pathOnDisk, 'descriptor.mod'));
    final knownMod = knownMods.values
        .where((mod) => PathService.samePath(mod.contentPath, pathOnDisk))
        .firstOrNull;

    final debugLower = debugText.replaceAll('\\', '/').toLowerCase();
    final normalizedLower = normalized.toLowerCase();
    final mounted = debugLower.contains('mounted data: $normalizedLower');
    final versionMatched = knownMod == null
        ? debugLower.contains('successfully matched game version') &&
              debugLower.contains(normalizedLower)
        : debugLower.contains('mod ${knownMod.name.toLowerCase()}') &&
              debugLower.contains('successfully matched game version');
    final versionMismatch = knownMod == null
        ? false
        : debugLower.contains('mod ${knownMod.name.toLowerCase()}') &&
              debugLower.contains('does not match game version');

    return DiagnosticModCheck(
      contentLoadPath: normalized,
      exists: folder.existsSync(),
      metadataExists: metadata.existsSync(),
      descriptorExists: descriptor.existsSync(),
      mountedLastRun: mounted,
      versionMatchedLastRun: versionMatched,
      versionMismatchLastRun: versionMismatch,
      knownModName: knownMod?.name,
    );
  }

  String _pathValue(Object? item) {
    if (item is Map) return item['path']?.toString() ?? '';
    return item?.toString() ?? '';
  }

  String _readText(File file) {
    try {
      return file.readAsStringSync();
    } catch (_) {
      return '';
    }
  }

  List<String> _interestingLines(
    String text,
    List<String> needles, {
    required int limit,
  }) {
    if (text.isEmpty) return const [];
    final lowerNeedles = needles.map((needle) => needle.toLowerCase()).toList();
    final lines = text.split(RegExp(r'\r?\n')).where((line) {
      final lower = line.toLowerCase();
      return lowerNeedles.any(lower.contains);
    }).toList();
    if (lines.length <= limit) return lines;
    return lines.sublist(lines.length - limit);
  }
}

class DiagnosticReport {
  const DiagnosticReport({
    required this.generatedAt,
    required this.gameRoot,
    required this.userDataPath,
    required this.gameVersion,
    required this.contentLoadPath,
    required this.contentLoadExists,
    required this.debugLogPath,
    required this.debugLogModified,
    required this.errorLogPath,
    required this.errorLogModified,
    required this.modChecks,
    required this.debugFindings,
    required this.errorFindings,
  });

  final DateTime generatedAt;
  final String gameRoot;
  final String userDataPath;
  final String gameVersion;
  final String contentLoadPath;
  final bool contentLoadExists;
  final String debugLogPath;
  final DateTime? debugLogModified;
  final String errorLogPath;
  final DateTime? errorLogModified;
  final List<DiagnosticModCheck> modChecks;
  final List<String> debugFindings;
  final List<String> errorFindings;

  bool get hasBlockingIssues {
    return !contentLoadExists ||
        modChecks.any(
          (check) =>
              !check.exists || !check.metadataExists || !check.mountedLastRun,
        );
  }

  String toDisplayText() {
    final buffer = StringBuffer()
      ..writeln('Victoria 3 Launcher Diagnosis')
      ..writeln('Generated: $generatedAt')
      ..writeln()
      ..writeln('Game root: $gameRoot')
      ..writeln('User data: $userDataPath')
      ..writeln(
        'Game version: ${gameVersion.isEmpty ? 'unknown' : gameVersion}',
      )
      ..writeln('content_load.json: $contentLoadPath')
      ..writeln('content_load exists: ${contentLoadExists ? 'yes' : 'no'}')
      ..writeln('debug.log modified: ${debugLogModified ?? 'missing'}')
      ..writeln('error.log modified: ${errorLogModified ?? 'missing'}')
      ..writeln()
      ..writeln(hasBlockingIssues ? 'Status: CHECK REQUIRED' : 'Status: OK')
      ..writeln();

    if (modChecks.isEmpty) {
      buffer.writeln('No enabled mods found in content_load.json.');
    } else {
      buffer.writeln('Enabled Mod Checks:');
      for (final check in modChecks) {
        buffer
          ..writeln('- ${check.knownModName ?? check.contentLoadPath}')
          ..writeln('  path: ${check.contentLoadPath}')
          ..writeln('  folder exists: ${check.exists ? 'yes' : 'no'}')
          ..writeln('  metadata exists: ${check.metadataExists ? 'yes' : 'no'}')
          ..writeln(
            '  descriptor exists: ${check.descriptorExists ? 'yes' : 'no'}',
          )
          ..writeln(
            '  mounted last run: ${check.mountedLastRun ? 'yes' : 'no'}',
          )
          ..writeln(
            '  version matched last run: ${check.versionMatchedLastRun
                ? 'yes'
                : check.versionMismatchLastRun
                ? 'mismatch'
                : 'unknown'}',
          );
      }
    }

    buffer
      ..writeln()
      ..writeln('Relevant debug.log lines:');
    if (debugFindings.isEmpty) {
      buffer.writeln('(none)');
    } else {
      for (final line in debugFindings) {
        buffer.writeln(line);
      }
    }

    buffer
      ..writeln()
      ..writeln('Relevant error.log lines:');
    if (errorFindings.isEmpty) {
      buffer.writeln('(none)');
    } else {
      for (final line in errorFindings) {
        buffer.writeln(line);
      }
    }

    return buffer.toString();
  }
}

class DiagnosticModCheck {
  const DiagnosticModCheck({
    required this.contentLoadPath,
    required this.exists,
    required this.metadataExists,
    required this.descriptorExists,
    required this.mountedLastRun,
    required this.versionMatchedLastRun,
    required this.versionMismatchLastRun,
    required this.knownModName,
  });

  final String contentLoadPath;
  final bool exists;
  final bool metadataExists;
  final bool descriptorExists;
  final bool mountedLastRun;
  final bool versionMatchedLastRun;
  final bool versionMismatchLastRun;
  final String? knownModName;
}
