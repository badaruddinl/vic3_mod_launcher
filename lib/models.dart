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
