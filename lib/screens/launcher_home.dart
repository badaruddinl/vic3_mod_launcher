import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../models.dart';
import '../services/active_mod_order_service.dart';
import '../services/app_logger.dart';
import '../services/content_load_service.dart';
import '../services/diagnostic_service.dart';
import '../services/dlc_library_service.dart';
import '../services/game_launch_service.dart';
import '../services/launcher_config.dart';
import '../services/mod_library_service.dart';
import '../services/mod_validation_service.dart';
import '../services/path_service.dart';
import '../services/playset_service.dart';
import '../services/update_service.dart';
import '../widgets/common/launcher_message_dialog.dart';
import '../widgets/settings/save_playset_dialog.dart';
import '../widgets/update/update_dialogs.dart';
import '../widgets/update/update_menu.dart';
import 'home_dashboard.dart';
import 'settings_screen.dart';

class LauncherHome extends StatefulWidget {
  const LauncherHome({super.key});

  @override
  State<LauncherHome> createState() => _LauncherHomeState();
}

class _LauncherHomeState extends State<LauncherHome> {
  late LauncherConfig config;
  final Map<String, ModInfo> mods = {};
  final List<String> activeModIds = [];
  final Set<String> selectedAvailable = {};
  final Set<String> selectedActive = {};
  final List<DlcInfo> dlcs = [];
  final Set<String> disabledDlcs = {};
  final List<String> logs = [];
  final Map<String, ModValidation> modValidations = {};
  List<SavedPlayset> savedPlaysets = const [];

  String gameVersion = '';
  bool loading = true;
  bool checkingUpdates = false;
  bool startupUpdateCheckDone = false;
  bool settingsOpen = false;
  int settingsInitialTabIndex = 0;
  UpdateCheckResult? availableUpdate;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    config = await LauncherConfig.load();
    await _refresh();
  }

  Future<void> _refresh() async {
    setState(() => loading = true);
    await config.save();
    Directory(config.userDataPath).createSync(recursive: true);
    Directory(config.modPath).createSync(recursive: true);

    gameVersion = PathService.detectGameVersion(config.gameRoot);
    if (config.autoRepair) {
      await _repairDescriptors(showDialogAfter: false);
    }

    mods
      ..clear()
      ..addAll(await _scanMods());
    _loadPlayset();
    _scanDlcs();
    _refreshValidations();
    _refreshSavedPlaysets();
    selectedAvailable.clear();
    selectedActive.clear();
    _log(
      'Loaded ${mods.length} mods, ${dlcs.length} DLC, game version: ${gameVersion.isEmpty ? 'unknown' : gameVersion}',
    );
    setState(() => loading = false);
    _checkForUpdatesOnStartup();
  }

  Future<Map<String, ModInfo>> _scanMods() async {
    return ModLibraryService(config: config, gameVersion: gameVersion).scan();
  }

  Future<void> _repairDescriptors({bool showDialogAfter = true}) async {
    final created = ModLibraryService(
      config: config,
      gameVersion: gameVersion,
    ).repairDescriptors();
    _log(
      'Descriptor repair complete. New .mod files: ${created < 0 ? 0 : created}',
    );
    if (showDialogAfter && mounted) {
      await _refresh();
      _showMessage(
        'Repair selesai',
        'Descriptor sudah dicek. File .mod dibuat untuk folder mod yang belum punya descriptor launcher.',
      );
    }
  }

  void _loadPlayset() {
    final state = const ContentLoadService().load(config: config, mods: mods);
    activeModIds
      ..clear()
      ..addAll(state.activeModIds);
    disabledDlcs
      ..clear()
      ..addAll(state.disabledDlcs);
  }

  void _scanDlcs() {
    dlcs
      ..clear()
      ..addAll(const DlcLibraryService().scan(config.gameRoot));
  }

  Future<void> _savePlayset({bool notify = true}) async {
    const contentLoad = ContentLoadService();
    final enabled = contentLoad.enabledModEntries(activeModIds, mods);
    final disabled = contentLoad.disabledDlcEntries(dlcs, disabledDlcs);
    contentLoad.save(
      config: config,
      mods: mods,
      activeModIds: activeModIds,
      dlcs: dlcs,
      disabledDlcs: disabledDlcs,
    );
    await config.save();
    _log(
      'Saved playset: ${enabled.length} active mods, ${disabled.length} disabled DLC',
    );
    if (notify && mounted) {
      _showMessage(
        'Playset tersimpan',
        'File content_load.json sudah diperbarui.',
      );
    }
  }

  Future<void> _restoreBackup() async {
    if (!const ContentLoadService().restoreBackup(config)) {
      _showMessage('Backup tidak ada', 'Belum ada backup content_load.json.');
      return;
    }
    await _refresh();
    _showMessage(
      'Backup dipulihkan',
      'content_load.json dipulihkan dari backup.',
    );
  }

  String _modIdFromContentLoadItem(Object? item) {
    return const ContentLoadService().modIdFromContentLoadItem(
      item,
      config: config,
      mods: mods,
    );
  }

  void _refreshValidations() {
    modValidations
      ..clear()
      ..addAll(
        const ModValidationService().validate(config: config, mods: mods),
      );
  }

  void _refreshSavedPlaysets() {
    savedPlaysets = const PlaysetService().list();
  }

  Future<void> _launchGame() async {
    try {
      await _savePlayset(notify: false);
      final result = await const GameLaunchService().launch(
        GameLaunchRequest(
          gameRoot: config.gameRoot,
          debugMode: config.debugMode,
        ),
      );
      _log(
        'Launch command sent. PID: ${result.pid.isEmpty ? 'unknown' : result.pid}. EXE: ${result.displayCommand}',
      );
    } on GameExecutableNotFoundException catch (error) {
      _showMessage('Game tidak ditemukan', error.toString());
    } catch (error) {
      _log('Launch failed: $error');
      _showMessage('Launch gagal', 'Game tidak berhasil dijalankan.\n\n$error');
    }
  }

  void _enableSelected() {
    setState(() {
      final next = const ActiveModOrderService().enableSelected(
        activeIds: activeModIds,
        selectedAvailable: selectedAvailable,
      );
      activeModIds
        ..clear()
        ..addAll(next);
      selectedAvailable.clear();
    });
  }

  void _disableSelected() {
    setState(() {
      final next = const ActiveModOrderService().disableSelected(
        activeIds: activeModIds,
        selectedActive: selectedActive,
      );
      activeModIds
        ..clear()
        ..addAll(next);
      selectedActive.clear();
    });
  }

  void _moveSelected(int delta) {
    if (selectedActive.isEmpty) return;
    setState(() {
      final next = const ActiveModOrderService().moveSelected(
        activeIds: activeModIds,
        selectedActive: selectedActive,
        delta: delta,
      );
      activeModIds
        ..clear()
        ..addAll(next);
    });
  }

  void _moveSelectedToEdge({required bool bottom}) {
    if (selectedActive.isEmpty) return;
    setState(() {
      final next = const ActiveModOrderService().moveSelectedToEdge(
        activeIds: activeModIds,
        selectedActive: selectedActive,
        bottom: bottom,
      );
      activeModIds
        ..clear()
        ..addAll(next);
    });
  }

  void _reorderActive(int oldIndex, int newIndex) {
    setState(() {
      final next = const ActiveModOrderService().reorder(
        activeIds: activeModIds,
        oldIndex: oldIndex,
        newIndex: newIndex,
      );
      activeModIds
        ..clear()
        ..addAll(next);
    });
  }

  Future<void> _importZip() async {
    final files = await openFiles(
      acceptedTypeGroups: [
        const XTypeGroup(label: 'ZIP mods', extensions: ['zip']),
      ],
    );
    if (files.isEmpty) return;
    var imported = 0;
    final errors = <String>[];
    for (final file in files) {
      try {
        ModLibraryService(
          config: config,
          gameVersion: gameVersion,
        ).extractZipMod(file.path);
        _log('Imported ZIP ${p.basename(file.path)}');
        imported += 1;
      } catch (error) {
        errors.add('${p.basename(file.path)}: $error');
      }
    }
    await _refresh();
    if (errors.isEmpty) {
      _showMessage('Import selesai', '$imported ZIP berhasil diimport.');
    } else {
      _showMessage('Import selesai dengan error', errors.join('\n'));
    }
  }

  Future<void> _pickUserData() async {
    final path = await getDirectoryPath(
      initialDirectory: Directory(config.userDataPath).existsSync()
          ? config.userDataPath
          : null,
    );
    if (path == null) return;
    setState(() => config = config.copyWith(userDataPath: path));
    await _refresh();
  }

  Future<void> _pickGameRoot() async {
    final path = await getDirectoryPath(
      initialDirectory: Directory(config.gameRoot).existsSync()
          ? config.gameRoot
          : null,
    );
    if (path == null) return;
    setState(() => config = config.copyWith(gameRoot: path));
    await _refresh();
  }

  Future<void> _autoDetectPaths() async {
    final shortcutRoot = await PathService.detectGameRootFromDesktopShortcut();
    final detectedGameRoot = shortcutRoot.isNotEmpty
        ? shortcutRoot
        : PathService.detectGameRoot();
    final detectedUserData = PathService.detectUserDataPath();

    setState(() {
      config = config.copyWith(
        gameRoot: detectedGameRoot,
        userDataPath: detectedUserData,
      );
    });
    await _refresh();
    _showMessage(
      'Auto detect selesai',
      'Game: ${detectedGameRoot.isEmpty ? 'tidak ditemukan' : detectedGameRoot}\nData: $detectedUserData',
    );
  }

  void _diagnose() {
    final report = const DiagnosticService().run(
      config: config,
      knownMods: mods,
      gameVersion: gameVersion,
    );
    _log(
      report.hasBlockingIssues ? 'Diagnosis: check required' : 'Diagnosis: OK',
    );
    _showMessage('Diagnosis', report.toDisplayText());
  }

  Future<void> _addExtraRoot() async {
    final path = await getDirectoryPath();
    if (path == null) return;
    final roots = [...config.extraModRoots];
    if (!roots.any((root) => PathService.samePath(root, path))) roots.add(path);
    setState(() => config = config.copyWith(extraModRoots: roots));
    await _refresh();
  }

  void _removeExtraRoot(String root) async {
    final roots = config.extraModRoots
        .where((item) => !PathService.samePath(item, root))
        .toList();
    setState(() => config = config.copyWith(extraModRoots: roots));
    await _refresh();
  }

  Future<void> _savePlaysetAs() async {
    final name = await showSavePlaysetDialog(context);
    if (name == null || name.trim().isEmpty) return;
    const contentLoad = ContentLoadService();
    const PlaysetService().save(
      name: name,
      enabledMods: contentLoad.enabledModEntries(activeModIds, mods),
      disabledDlc: contentLoad.disabledDlcEntries(dlcs, disabledDlcs),
    );
    setState(_refreshSavedPlaysets);
    _log('Saved named playset: ${name.trim()}');
  }

  Future<void> _loadSavedPlayset(SavedPlayset playset) async {
    final data = const PlaysetService().load(playset);
    activeModIds.clear();
    disabledDlcs.clear();

    final enabled = (data['orderedListMods'] as List?)?.isNotEmpty == true
        ? data['orderedListMods'] as List
        : data['enabledMods'] as List? ?? const [];
    for (final item in enabled) {
      final id = _modIdFromContentLoadItem(item);
      if (id.isNotEmpty && mods.containsKey(id) && !activeModIds.contains(id)) {
        activeModIds.add(id);
      }
    }

    for (final item in data['disabledDLC'] as List? ?? const []) {
      disabledDlcs.add(
        const ContentLoadService()
            .pathValue(item)
            .replaceAll('\\', '/')
            .toLowerCase(),
      );
    }
    await _savePlayset(notify: false);
    setState(() {});
    _showMessage(
      'Playset dimuat',
      'Playset "${playset.name}" sudah dimuat dan disimpan.',
    );
  }

  void _deleteSavedPlayset(SavedPlayset playset) {
    const PlaysetService().delete(playset);
    setState(_refreshSavedPlaysets);
    _log('Deleted playset: ${playset.name}');
  }

  Future<void> _checkForUpdates() async {
    if (checkingUpdates) return;
    setState(() => checkingUpdates = true);
    try {
      final result = await const UpdateService().check(
        config.updateManifestUrl,
      );
      _log(
        'Update check: current ${result.current.label}, latest ${result.latest.label}',
      );
      if (mounted) {
        setState(
          () => availableUpdate = result.updateAvailable ? result : null,
        );
      }
      if (!mounted) return;
      if (!result.updateAvailable) {
        _showMessage(
          'Tidak ada update',
          'Versi terpasang sudah terbaru.\n\nCurrent: ${result.current.label}\nLatest: ${result.latest.label}',
        );
        return;
      }
      await _showUpdateDialog(result);
    } catch (error) {
      _log('Update check failed: $error');
      if (mounted) {
        _showMessage('Update gagal dicek', error.toString());
      }
    } finally {
      if (mounted) setState(() => checkingUpdates = false);
    }
  }

  Future<void> _checkForUpdatesOnStartup() async {
    if (startupUpdateCheckDone || checkingUpdates) return;
    startupUpdateCheckDone = true;
    try {
      final result = await const UpdateService().check(
        config.updateManifestUrl,
      );
      _log(
        'Startup update check: current ${result.current.label}, latest ${result.latest.label}',
      );
      if (!mounted) return;
      if (result.updateAvailable) {
        setState(() => availableUpdate = result);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Update ${result.latest.label} tersedia'),
            action: SnackBarAction(
              label: 'View',
              onPressed: () => _showUpdateDialog(result),
            ),
          ),
        );
      }
    } catch (error) {
      _log('Startup update check failed: $error');
    }
  }

  Future<void> _showUpdateDialog(UpdateCheckResult result) async {
    final install = await showUpdateAvailableDialog(context, result);
    if (install == true) {
      await _downloadAndInstallUpdate(result.latest);
    }
  }

  Future<void> _downloadAndInstallUpdate(UpdateInfo update) async {
    final progressDialog = UpdateDownloadProgressDialog();
    progressDialog.show(context, update);
    await Future<void>.delayed(const Duration(milliseconds: 100));

    try {
      final installer = await const UpdateService().downloadInstaller(
        update,
        onProgress: (nextReceived, nextTotal) {
          progressDialog.update(nextReceived, nextTotal);
        },
      );
      if (mounted) Navigator.of(context).pop();
      await const UpdateService().launchInstaller(installer);
      _log('Update installer launched: ${installer.path}');
    } catch (error) {
      if (mounted) Navigator.of(context).pop();
      _log('Update download failed: $error');
      if (mounted) {
        _showMessage('Update gagal didownload', error.toString());
      }
    }
  }

  Future<void> _editUpdateSource() async {
    final value = await showUpdateSourceDialog(
      context,
      initialValue: config.updateManifestUrl,
    );
    if (value == null || value.trim().isEmpty) return;
    setState(() => config = config.copyWith(updateManifestUrl: value.trim()));
    await config.save();
    _log('Update source changed: ${value.trim()}');
  }

  List<String> get availableModIds {
    final ids = mods.keys.where((id) => !activeModIds.contains(id)).toList();
    ids.sort(
      (a, b) =>
          mods[a]!.name.toLowerCase().compareTo(mods[b]!.name.toLowerCase()),
    );
    return ids;
  }

  void _log(String message) {
    final stamp = DateTime.now().toIso8601String().substring(11, 19);
    logs.insert(0, '[$stamp] $message');
    if (logs.length > 200) logs.removeRange(200, logs.length);
    AppLogger.info(message);
    if (mounted) setState(() {});
  }

  void _showMessage(String title, String body) {
    showLauncherMessageDialog(context, title: title, body: body);
  }

  void _openSettings({int initialTabIndex = 0}) {
    setState(() {
      settingsInitialTabIndex = initialTabIndex;
      settingsOpen = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: Color(0xff071314),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final updateMenu = _buildUpdateMenu();
    if (settingsOpen) {
      return LauncherSettingsScreen(
        config: config,
        gameVersion: gameVersion,
        mods: mods,
        availableModIds: availableModIds,
        activeModIds: activeModIds,
        selectedAvailable: selectedAvailable,
        selectedActive: selectedActive,
        validations: modValidations,
        dlcs: dlcs,
        disabledDlcs: disabledDlcs,
        playsets: savedPlaysets,
        logs: logs,
        updateMenu: updateMenu,
        initialTabIndex: settingsInitialTabIndex,
        onBack: () => setState(() => settingsOpen = false),
        onPickUserData: _pickUserData,
        onPickGameRoot: _pickGameRoot,
        onAutoDetect: _autoDetectPaths,
        onRefresh: _refresh,
        onDiagnose: _diagnose,
        onImportZip: _importZip,
        onRepair: () => _repairDescriptors(showDialogAfter: true),
        onRestoreBackup: _restoreBackup,
        onSavePlayset: _savePlayset,
        onSavePlaysetAs: _savePlaysetAs,
        onLoadPlayset: _loadSavedPlayset,
        onDeletePlayset: _deleteSavedPlayset,
        onAutoRepairChanged: (value) async {
          setState(() => config = config.copyWith(autoRepair: value));
          await _refresh();
        },
        onDebugModeChanged: (value) async {
          setState(() => config = config.copyWith(debugMode: value));
          await config.save();
          _log('Debug mode ${value ? 'enabled' : 'disabled'}');
        },
        onAddExtraRoot: _addExtraRoot,
        onRemoveExtraRoot: _removeExtraRoot,
        onAvailableTap: (id) => setState(
          () => selectedAvailable.contains(id)
              ? selectedAvailable.remove(id)
              : selectedAvailable.add(id),
        ),
        onActiveTap: (id) => setState(
          () => selectedActive.contains(id)
              ? selectedActive.remove(id)
              : selectedActive.add(id),
        ),
        onActiveReorder: _reorderActive,
        onEnable: _enableSelected,
        onDisable: _disableSelected,
        onUp: () => _moveSelected(-1),
        onDown: () => _moveSelected(1),
        onTop: () => _moveSelectedToEdge(bottom: false),
        onBottom: () => _moveSelectedToEdge(bottom: true),
        onToggleDlc: (dlc) {
          setState(() {
            final key = dlc.ref.toLowerCase();
            disabledDlcs.contains(key)
                ? disabledDlcs.remove(key)
                : disabledDlcs.add(key);
          });
        },
        onEnableAllDlc: () => setState(disabledDlcs.clear),
      );
    }

    return HomeDashboard(
      gameVersion: gameVersion,
      mods: mods,
      activeModIds: activeModIds,
      validations: modValidations,
      updateMenu: updateMenu,
      onLaunch: _launchGame,
      onOpenSettings: () => _openSettings(),
      onOpenMods: () => _openSettings(initialTabIndex: 1),
    );
  }

  Widget _buildUpdateMenu() {
    return LauncherUpdateMenu(
      checking: checkingUpdates,
      availableUpdate: availableUpdate,
      onCheck: _checkForUpdates,
      onViewUpdate: () {
        final update = availableUpdate;
        if (update != null) _showUpdateDialog(update);
      },
      onEditSource: _editUpdateSource,
    );
  }
}
