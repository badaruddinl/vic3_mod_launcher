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

class AppVersion {
  const AppVersion({required this.version, required this.buildNumber});

  final String version;
  final int buildNumber;

  String get label => buildNumber > 0 ? '$version+$buildNumber' : version;
}

class UpdateInfo {
  const UpdateInfo({
    required this.version,
    required this.buildNumber,
    required this.installerUrl,
    required this.sha256,
    required this.notes,
    required this.publishedAt,
  });

  final String version;
  final int buildNumber;
  final String installerUrl;
  final String sha256;
  final String notes;
  final DateTime? publishedAt;

  String get label => buildNumber > 0 ? '$version+$buildNumber' : version;
}

class UpdateCheckResult {
  const UpdateCheckResult({
    required this.current,
    required this.latest,
    required this.updateAvailable,
  });

  final AppVersion current;
  final UpdateInfo latest;
  final bool updateAvailable;
}
