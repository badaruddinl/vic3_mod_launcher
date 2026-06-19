import 'dart:io';

import 'package:path/path.dart' as p;

import '../models.dart';
import 'launcher_config.dart';
import 'path_service.dart';

class ModValidationService {
  const ModValidationService();

  Map<String, ModValidation> validate({
    required LauncherConfig config,
    required Map<String, ModInfo> mods,
  }) {
    final debugLog = File(p.join(config.userDataPath, 'logs', 'debug.log'));
    final debugText = debugLog.existsSync()
        ? debugLog.readAsStringSync().replaceAll('\\', '/').toLowerCase()
        : '';
    return Map.fromEntries(
      mods.entries.map((entry) {
        final mod = entry.value;
        final contentPath = PathService.normalizePath(mod.contentPath);
        final diskPath = contentPath.replaceAll('/', p.separator);
        final validation = ModValidation(
          folderExists: Directory(diskPath).existsSync(),
          metadataExists: File(
            p.join(diskPath, '.metadata', 'metadata.json'),
          ).existsSync(),
          descriptorExists: File(
            p.join(diskPath, 'descriptor.mod'),
          ).existsSync(),
          mountedLastRun: debugText.contains(
            'mounted data: ${contentPath.toLowerCase()}',
          ),
        );
        return MapEntry(entry.key, validation);
      }),
    );
  }
}
