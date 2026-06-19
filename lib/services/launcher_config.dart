import 'package:path/path.dart' as p;

import '../constants.dart';
import 'json_service.dart';
import 'path_service.dart';

class LauncherConfig {
  const LauncherConfig({
    required this.userDataPath,
    required this.gameRoot,
    required this.extraModRoots,
    required this.autoRepair,
    required this.debugMode,
    required this.updateManifestUrl,
  });

  final String userDataPath;
  final String gameRoot;
  final List<String> extraModRoots;
  final bool autoRepair;
  final bool debugMode;
  final String updateManifestUrl;

  String get modPath => p.join(userDataPath, 'mod');
  String get contentLoadPath => p.join(userDataPath, 'content_load.json');
  String get legacyDlcLoadPath => p.join(userDataPath, 'dlc_load.json');

  LauncherConfig copyWith({
    String? userDataPath,
    String? gameRoot,
    List<String>? extraModRoots,
    bool? autoRepair,
    bool? debugMode,
    String? updateManifestUrl,
  }) {
    return LauncherConfig(
      userDataPath: userDataPath ?? this.userDataPath,
      gameRoot: gameRoot ?? this.gameRoot,
      extraModRoots: extraModRoots ?? this.extraModRoots,
      autoRepair: autoRepair ?? this.autoRepair,
      debugMode: debugMode ?? this.debugMode,
      updateManifestUrl: updateManifestUrl ?? this.updateManifestUrl,
    );
  }

  static Future<LauncherConfig> load() async {
    final json = readJsonMap(PathService.configPath());
    final shortcutRoot = await PathService.detectGameRootFromDesktopShortcut();
    final savedGameRoot = (json['gameRoot'] as String?)?.trim();
    final savedUserData = (json['userDataPath'] as String?)?.trim();
    final detectedGameRoot = shortcutRoot.isNotEmpty
        ? shortcutRoot
        : PathService.detectGameRoot();
    final detectedUserData = PathService.detectUserDataPath();

    return LauncherConfig(
      userDataPath:
          savedUserData?.isNotEmpty == true &&
              PathService.isLikelyVictoriaUserData(savedUserData!)
          ? savedUserData
          : detectedUserData,
      gameRoot:
          savedGameRoot?.isNotEmpty == true &&
              PathService.isValidGameRoot(savedGameRoot!)
          ? savedGameRoot
          : detectedGameRoot,
      extraModRoots: ((json['extraModRoots'] as List?) ?? const [])
          .map((item) => item.toString())
          .where((item) => item.trim().isNotEmpty)
          .toList(),
      autoRepair: json['autoRepair'] as bool? ?? true,
      debugMode: json['debugMode'] as bool? ?? false,
      updateManifestUrl:
          (json['updateManifestUrl'] as String?)?.trim().isNotEmpty == true
          ? (json['updateManifestUrl'] as String).trim()
          : defaultUpdateManifestUrl,
    );
  }

  Future<void> save() async {
    writePrettyJson(PathService.configPath(), {
      'userDataPath': userDataPath,
      'gameRoot': gameRoot,
      'extraModRoots': extraModRoots,
      'autoRepair': autoRepair,
      'debugMode': debugMode,
      'updateManifestUrl': updateManifestUrl,
    });
  }
}
