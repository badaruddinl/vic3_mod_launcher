import 'package:path/path.dart' as p;

class ModInfo {
  const ModInfo({
    required this.id,
    required this.name,
    required this.modFile,
    required this.contentPath,
    required this.source,
    required this.supportedVersion,
    required this.version,
    required this.remoteFileId,
    required this.compatible,
  });

  final String id;
  final String name;
  final String modFile;
  final String contentPath;
  final String source;
  final String supportedVersion;
  final String version;
  final String remoteFileId;
  final VersionStatus compatible;

  String get modRef => 'mod/${p.basename(modFile)}';
}

class DlcInfo {
  const DlcInfo({required this.name, required this.ref, required this.path});

  final String name;
  final String ref;
  final String path;
}

enum VersionStatus { ok, warning, unknown }

class ModValidation {
  const ModValidation({
    required this.folderExists,
    required this.metadataExists,
    required this.descriptorExists,
    required this.mountedLastRun,
  });

  final bool folderExists;
  final bool metadataExists;
  final bool descriptorExists;
  final bool mountedLastRun;

  ModHealth get health {
    if (!folderExists || !metadataExists) return ModHealth.error;
    if (!descriptorExists || !mountedLastRun) return ModHealth.warning;
    return ModHealth.ok;
  }
}

enum ModHealth { ok, warning, error }

class SavedPlayset {
  const SavedPlayset({
    required this.name,
    required this.path,
    required this.modifiedAt,
  });

  final String name;
  final String path;
  final DateTime modifiedAt;
}
