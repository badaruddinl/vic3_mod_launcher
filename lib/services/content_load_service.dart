import 'dart:io';

import '../models.dart';
import 'json_service.dart';
import 'launcher_config.dart';
import 'path_service.dart';

class ContentLoadState {
  const ContentLoadState({
    required this.activeModIds,
    required this.disabledDlcs,
  });

  final List<String> activeModIds;
  final Set<String> disabledDlcs;
}

class ContentLoadService {
  const ContentLoadService();

  ContentLoadState load({
    required LauncherConfig config,
    required Map<String, ModInfo> mods,
  }) {
    var json = readJsonMap(config.contentLoadPath);
    if (json.isEmpty) {
      json = readJsonMap(config.legacyDlcLoadPath);
    }

    final activeModIds = <String>[];
    final enabledMods = (json['orderedListMods'] as List?)?.isNotEmpty == true
        ? json['orderedListMods'] as List
        : (json['enabledMods'] as List? ??
              json['enabled_mods'] as List? ??
              const []);
    for (final item in enabledMods) {
      final id = modIdFromContentLoadItem(item, config: config, mods: mods);
      if (id.isNotEmpty && mods.containsKey(id) && !activeModIds.contains(id)) {
        activeModIds.add(id);
      }
    }

    final disabledDlcs = <String>{};
    final disabledDlc =
        json['disabledDLC'] as List? ??
        json['disabled_dlcs'] as List? ??
        const [];
    for (final item in disabledDlc) {
      disabledDlcs.add(pathValue(item).replaceAll('\\', '/').toLowerCase());
    }

    return ContentLoadState(
      activeModIds: activeModIds,
      disabledDlcs: disabledDlcs,
    );
  }

  void save({
    required LauncherConfig config,
    required Map<String, ModInfo> mods,
    required List<String> activeModIds,
    required List<DlcInfo> dlcs,
    required Set<String> disabledDlcs,
  }) {
    backup(config);
    final enabled = enabledModEntries(activeModIds, mods);
    writePrettyJson(config.contentLoadPath, {
      'enabledMods': enabled,
      'orderedListMods': enabled,
      'disabledDLC': disabledDlcEntries(dlcs, disabledDlcs),
      'enabledUGC': [],
    });
  }

  List<Map<String, String>> enabledModEntries(
    List<String> activeModIds,
    Map<String, ModInfo> mods,
  ) {
    return activeModIds
        .where(mods.containsKey)
        .map((id) => {'path': contentLoadRefForMod(mods[id]!)})
        .toList();
  }

  List<Map<String, String>> disabledDlcEntries(
    List<DlcInfo> dlcs,
    Set<String> disabledDlcs,
  ) {
    final disabled = <Map<String, String>>[];
    for (final dlc in dlcs) {
      if (disabledDlcs.contains(dlc.ref.toLowerCase())) {
        disabled.add({'path': dlc.ref});
      }
    }
    return disabled;
  }

  String backupPath(LauncherConfig config) => '${config.contentLoadPath}.bak';

  void backup(LauncherConfig config) {
    final source = File(config.contentLoadPath);
    if (!source.existsSync()) return;
    source.copySync(backupPath(config));
  }

  bool restoreBackup(LauncherConfig config) {
    final backupFile = File(backupPath(config));
    if (!backupFile.existsSync()) return false;
    backupFile.copySync(config.contentLoadPath);
    return true;
  }

  String pathValue(Object? item) {
    if (item is Map) {
      return item['path']?.toString() ?? '';
    }
    return item?.toString() ?? '';
  }

  String modIdFromContentLoadItem(
    Object? item, {
    required LauncherConfig config,
    required Map<String, ModInfo> mods,
  }) {
    final value = pathValue(item).replaceAll('\\', '/');
    if (value.trim().isEmpty) return '';
    final descriptorId = value.toLowerCase();
    if (mods.containsKey(descriptorId)) return descriptorId;

    final resolved = PathService.resolveContentPath(
      value,
      config.userDataPath,
      config.userDataPath,
    );
    for (final mod in mods.values) {
      if (PathService.samePath(mod.contentPath, resolved)) return mod.id;
    }
    return '';
  }

  String contentLoadRefForMod(ModInfo mod) {
    return PathService.normalizePath(mod.contentPath);
  }
}
