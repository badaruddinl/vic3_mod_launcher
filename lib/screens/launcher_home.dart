import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../constants.dart';
import '../models.dart';
import '../services/diagnostic_service.dart';
import '../services/descriptor_service.dart';
import '../services/json_service.dart';
import '../services/launcher_config.dart';
import '../services/path_service.dart';
import '../widgets/mod_manager.dart';
import '../widgets/path_header.dart';
import '../widgets/side_panel.dart';

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

  String gameVersion = '';
  bool loading = true;

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

    if (config.autoRepair) {
      await _repairDescriptors(showDialogAfter: false);
    }

    gameVersion = PathService.detectGameVersion(config.gameRoot);
    mods
      ..clear()
      ..addAll(await _scanMods());
    _loadPlayset();
    _scanDlcs();
    selectedAvailable.clear();
    selectedActive.clear();
    _log(
      'Loaded ${mods.length} mods, ${dlcs.length} DLC, game version: ${gameVersion.isEmpty ? 'unknown' : gameVersion}',
    );
    setState(() => loading = false);
  }

  Future<Map<String, ModInfo>> _scanMods() async {
    final result = <String, ModInfo>{};
    final modDir = Directory(config.modPath);

    for (final file in modDir.listSync().whereType<File>()) {
      if (!file.path.toLowerCase().endsWith('.mod')) continue;
      final info = _modFromDescriptor(file);
      if (info != null) result[info.id] = info;
    }

    for (final dir in modDir.listSync().whereType<Directory>()) {
      final descriptor = File(p.join(dir.path, 'descriptor.mod'));
      final hasKnownMod = result.values.any(
        (mod) => PathService.samePath(mod.contentPath, dir.path),
      );
      if (!hasKnownMod && (descriptor.existsSync() || config.autoRepair)) {
        final modFile = _ensureModFileForFolder(dir.path, localFolder: true);
        final info = _modFromDescriptor(File(modFile));
        if (info != null) result[info.id] = info;
      }
    }

    for (final rootPath in config.extraModRoots) {
      final root = Directory(rootPath);
      if (!root.existsSync()) continue;
      for (final dir in root.listSync().whereType<Directory>()) {
        final descriptor = File(p.join(dir.path, 'descriptor.mod'));
        if (!descriptor.existsSync()) continue;
        final modFile = _ensureModFileForFolder(dir.path, localFolder: false);
        final info = _modFromDescriptor(File(modFile));
        if (info != null) result[info.id] = info;
      }
    }

    return result;
  }

  ModInfo? _modFromDescriptor(File modFile) {
    final data = DescriptorService.parseDescriptorFile(modFile.path);
    final rawPath = data['path'] ?? data['archive'] ?? '';
    final contentPath = PathService.resolveContentPath(
      rawPath,
      p.dirname(modFile.path),
      config.userDataPath,
    );
    final name = (data['name'] ?? p.basenameWithoutExtension(modFile.path))
        .trim();
    final supported = data['supported_version'] ?? '';
    final source = PathService.isUnder(contentPath, config.modPath)
        ? 'local'
        : 'external';
    final id = PathService.modRefForFile(modFile.path).toLowerCase();
    return ModInfo(
      id: id,
      name: name.isEmpty ? p.basenameWithoutExtension(modFile.path) : name,
      modFile: modFile.path,
      contentPath: contentPath,
      source: source,
      supportedVersion: supported,
      version: data['version'] ?? '',
      remoteFileId: data['remote_file_id'] ?? '',
      compatible: PathService.versionCompatible(gameVersion, supported),
    );
  }

  String _ensureModFileForFolder(
    String folderPath, {
    required bool localFolder,
  }) {
    final folder = Directory(folderPath);
    final descriptor = File(p.join(folder.path, 'descriptor.mod'));
    final data = descriptor.existsSync()
        ? DescriptorService.parseDescriptorFile(descriptor.path)
        : <String, String>{};
    final name = (data['name'] ?? p.basename(folder.path)).trim();
    final modName = PathService.safeName(p.basename(folder.path));
    final modFile = File(
      PathService.uniquePath(p.join(config.modPath, '$modName.mod')),
    );
    final existing = _findExistingModForFolder(folder.path);
    final pathValue =
        localFolder && PathService.isUnder(folder.path, config.userDataPath)
        ? PathService.normalizePath(
            p.relative(folder.path, from: config.userDataPath),
          )
        : PathService.normalizePath(folder.path);
    final supportedVersion =
        data['supported_version'] ?? PathService.wildcardVersion(gameVersion);
    final version = data['version'] ?? '1.0';

    if (!descriptor.existsSync()) {
      descriptor.writeAsStringSync(
        DescriptorService.descriptorText(
          name: name.isEmpty ? modName : name,
          pathValue: pathValue,
          supportedVersion: supportedVersion,
          version: version,
          remoteFileId: data['remote_file_id'],
        ),
        encoding: utf8,
      );
    }

    if (existing != null) return existing;
    modFile.writeAsStringSync(
      DescriptorService.descriptorText(
        name: name.isEmpty ? modName : name,
        pathValue: pathValue,
        supportedVersion: supportedVersion,
        version: version,
        remoteFileId: data['remote_file_id'],
      ),
      encoding: utf8,
    );
    return modFile.path;
  }

  String? _findExistingModForFolder(String folderPath) {
    final modDir = Directory(config.modPath);
    if (!modDir.existsSync()) return null;
    for (final file in modDir.listSync().whereType<File>()) {
      if (!file.path.toLowerCase().endsWith('.mod')) continue;
      final data = DescriptorService.parseDescriptorFile(file.path);
      final rawPath = data['path'] ?? data['archive'] ?? '';
      final resolved = PathService.resolveContentPath(
        rawPath,
        p.dirname(file.path),
        config.userDataPath,
      );
      if (PathService.samePath(resolved, folderPath)) return file.path;
    }
    return null;
  }

  Future<void> _repairDescriptors({bool showDialogAfter = true}) async {
    final modDir = Directory(config.modPath)..createSync(recursive: true);
    final before = modDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.toLowerCase().endsWith('.mod'))
        .length;

    for (final dir in modDir.listSync().whereType<Directory>()) {
      _ensureModFileForFolder(dir.path, localFolder: true);
    }

    for (final rootPath in config.extraModRoots) {
      final root = Directory(rootPath);
      if (!root.existsSync()) continue;
      for (final dir in root.listSync().whereType<Directory>()) {
        if (File(p.join(dir.path, 'descriptor.mod')).existsSync()) {
          _ensureModFileForFolder(dir.path, localFolder: false);
        }
      }
    }

    final after = modDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.toLowerCase().endsWith('.mod'))
        .length;
    final created = after - before;
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
    activeModIds.clear();
    disabledDlcs.clear();

    var json = readJsonMap(config.contentLoadPath);
    if (json.isEmpty) {
      json = readJsonMap(config.legacyDlcLoadPath);
    }

    final enabledMods = (json['orderedListMods'] as List?)?.isNotEmpty == true
        ? json['orderedListMods'] as List
        : (json['enabledMods'] as List? ??
              json['enabled_mods'] as List? ??
              const []);
    for (final item in enabledMods) {
      final id = _modIdFromContentLoadItem(item);
      if (id.isNotEmpty && mods.containsKey(id) && !activeModIds.contains(id)) {
        activeModIds.add(id);
      }
    }

    final disabledDlc =
        json['disabledDLC'] as List? ??
        json['disabled_dlcs'] as List? ??
        const [];
    for (final item in disabledDlc) {
      disabledDlcs.add(
        _contentLoadPathValue(item).replaceAll('\\', '/').toLowerCase(),
      );
    }
  }

  void _scanDlcs() {
    dlcs.clear();
    final root = Directory(config.gameRoot);
    if (!root.existsSync()) return;
    final candidates = [
      Directory(p.join(root.path, 'game', 'dlc')),
      Directory(p.join(root.path, 'dlc')),
    ];
    for (final base in candidates) {
      if (!base.existsSync()) continue;
      for (final file in base.listSync(recursive: true).whereType<File>()) {
        if (!file.path.toLowerCase().endsWith('.dlc')) continue;
        final data = DescriptorService.parseDescriptorFile(file.path);
        final ref = PathService.relativeDlcRef(file.path, config.gameRoot);
        dlcs.add(
          DlcInfo(
            name: data['name'] ?? p.basename(p.dirname(file.path)),
            ref: ref,
            path: file.path,
          ),
        );
      }
    }
    dlcs.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  Future<void> _savePlayset({bool notify = true}) async {
    final enabled = activeModIds
        .where(mods.containsKey)
        .map((id) => {'path': _contentLoadRefForMod(mods[id]!)})
        .toList();
    final disabled = <Map<String, String>>[];
    for (final dlc in dlcs) {
      if (disabledDlcs.contains(dlc.ref.toLowerCase())) {
        disabled.add({'path': dlc.ref});
      }
    }
    writePrettyJson(config.contentLoadPath, {
      'enabledMods': enabled,
      'orderedListMods': enabled,
      'disabledDLC': disabled,
      'enabledUGC': [],
    });
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

  String _contentLoadPathValue(Object? item) {
    if (item is Map) {
      return item['path']?.toString() ?? '';
    }
    return item?.toString() ?? '';
  }

  String _modIdFromContentLoadItem(Object? item) {
    final value = _contentLoadPathValue(item).replaceAll('\\', '/');
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

  String _contentLoadRefForMod(ModInfo mod) {
    return PathService.normalizePath(mod.contentPath);
  }

  Future<void> _launchGame() async {
    try {
      await _savePlayset(notify: false);
      final exe = PathService.findGameExe(config.gameRoot);
      if (exe.isEmpty) {
        _showMessage(
          'Game tidak ditemukan',
          'victoria3.exe tidak ditemukan. Pilih folder install Victoria 3 yang benar.',
        );
        return;
      }
      final args = config.debugMode ? ['-debug_mode'] : <String>[];
      final pid = await _startGameProcess(exe, args);
      _log(
        'Launch command sent. PID: ${pid.isEmpty ? 'unknown' : pid}. EXE: $exe ${args.join(' ')}',
      );
    } catch (error) {
      _log('Launch failed: $error');
      _showMessage('Launch gagal', 'Game tidak berhasil dijalankan.\n\n$error');
    }
  }

  Future<String> _startGameProcess(String exe, List<String> args) async {
    if (!Platform.isWindows) {
      final process = await Process.start(
        exe,
        args,
        workingDirectory: p.dirname(exe),
        mode: ProcessStartMode.detached,
      );
      return process.pid.toString();
    }

    const script = r'''
$ErrorActionPreference = 'Stop'
$file = $env:VIC3_LAUNCH_FILE
$work = $env:VIC3_LAUNCH_WORK
$argLine = $env:VIC3_LAUNCH_ARGS
if ([string]::IsNullOrWhiteSpace($argLine)) {
  $process = Start-Process -FilePath $file -WorkingDirectory $work -PassThru
} else {
  $process = Start-Process -FilePath $file -WorkingDirectory $work -ArgumentList $argLine -PassThru
}
$process.Id
''';
    final result = await Process.run(
      'powershell',
      ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-Command', script],
      environment: {
        'VIC3_LAUNCH_FILE': exe,
        'VIC3_LAUNCH_WORK': p.dirname(exe),
        'VIC3_LAUNCH_ARGS': args.join(' '),
      },
    );
    if (result.exitCode != 0) {
      final stderr = result.stderr.toString().trim();
      final stdout = result.stdout.toString().trim();
      throw Exception(
        [
          if (stderr.isNotEmpty) stderr,
          if (stdout.isNotEmpty) stdout,
          if (stderr.isEmpty && stdout.isEmpty)
            'PowerShell Start-Process exit code ${result.exitCode}',
        ].join('\n'),
      );
    }
    return result.stdout.toString().trim();
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
        _extractZipMod(file.path);
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

  void _extractZipMod(String zipPath) {
    final bytes = File(zipPath).readAsBytesSync();
    final archive = ZipDecoder().decodeBytes(bytes);
    final target = Directory(
      PathService.uniquePath(
        p.join(
          config.modPath,
          PathService.safeName(p.basenameWithoutExtension(zipPath)),
        ),
      ),
    )..createSync(recursive: true);
    for (final entry in archive.files) {
      if (!entry.isFile) continue;
      final cleanName = entry.name.replaceAll('\\', '/');
      final parts = cleanName
          .split('/')
          .where((part) => part.isNotEmpty)
          .toList();
      if (parts.any((part) => part == '..')) continue;
      final output = File(p.joinAll([target.path, ...parts]))
        ..parent.createSync(recursive: true);
      output.writeAsBytesSync(entry.content as List<int>);
    }
    _flattenSingleRoot(target);
    _ensureModFileForFolder(target.path, localFolder: true);
    _log('Imported ZIP ${p.basename(zipPath)} to ${target.path}');
  }

  void _flattenSingleRoot(Directory target) {
    final entries = target.listSync();
    final dirs = entries.whereType<Directory>().toList();
    final files = entries.whereType<File>().toList();
    if (files.isNotEmpty || dirs.length != 1) return;
    final root = dirs.single;
    for (final item in root.listSync()) {
      item.renameSync(p.join(target.path, p.basename(item.path)));
    }
    root.deleteSync();
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

  void _enableSelected() {
    setState(() {
      for (final id in selectedAvailable) {
        if (!activeModIds.contains(id)) activeModIds.add(id);
      }
      selectedAvailable.clear();
    });
  }

  void _disableSelected() {
    setState(() {
      activeModIds.removeWhere(selectedActive.contains);
      selectedActive.clear();
    });
  }

  void _moveSelected(int delta) {
    if (selectedActive.isEmpty) return;
    setState(() {
      if (delta < 0) {
        for (var i = 1; i < activeModIds.length; i++) {
          if (selectedActive.contains(activeModIds[i]) &&
              !selectedActive.contains(activeModIds[i - 1])) {
            final temp = activeModIds[i - 1];
            activeModIds[i - 1] = activeModIds[i];
            activeModIds[i] = temp;
          }
        }
      } else {
        for (var i = activeModIds.length - 2; i >= 0; i--) {
          if (selectedActive.contains(activeModIds[i]) &&
              !selectedActive.contains(activeModIds[i + 1])) {
            final temp = activeModIds[i + 1];
            activeModIds[i + 1] = activeModIds[i];
            activeModIds[i] = temp;
          }
        }
      }
    });
  }

  void _moveSelectedToEdge({required bool bottom}) {
    if (selectedActive.isEmpty) return;
    setState(() {
      final selected = activeModIds.where(selectedActive.contains).toList();
      final rest = activeModIds
          .where((id) => !selectedActive.contains(id))
          .toList();
      activeModIds
        ..clear()
        ..addAll(bottom ? [...rest, ...selected] : [...selected, ...rest]);
    });
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
    if (mounted) setState(() {});
  }

  void _showMessage(String title, String body) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SelectableText(body),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(appName),
        actions: [
          Row(
            children: [
              const Text('Debug mode'),
              Switch(
                value: config.debugMode,
                onChanged: (value) async {
                  setState(() => config = config.copyWith(debugMode: value));
                  await config.save();
                  _log('Debug mode ${value ? 'enabled' : 'disabled'}');
                },
              ),
              const SizedBox(width: 12),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          PathHeader(
            config: config,
            gameVersion: gameVersion,
            onPickUserData: _pickUserData,
            onPickGameRoot: _pickGameRoot,
            onAutoDetect: _autoDetectPaths,
            onRefresh: _refresh,
            onDiagnose: _diagnose,
            onImportZip: _importZip,
            onRepair: () => _repairDescriptors(showDialogAfter: true),
            onSave: _savePlayset,
            onLaunch: _launchGame,
            onAutoRepairChanged: (value) async {
              setState(() => config = config.copyWith(autoRepair: value));
              await _refresh();
            },
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: ModManager(
                    mods: mods,
                    availableIds: availableModIds,
                    activeIds: activeModIds,
                    selectedAvailable: selectedAvailable,
                    selectedActive: selectedActive,
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
                    onEnable: _enableSelected,
                    onDisable: _disableSelected,
                    onUp: () => _moveSelected(-1),
                    onDown: () => _moveSelected(1),
                    onTop: () => _moveSelectedToEdge(bottom: false),
                    onBottom: () => _moveSelectedToEdge(bottom: true),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: SidePanel(
                    config: config,
                    dlcs: dlcs,
                    disabledDlcs: disabledDlcs,
                    logs: logs,
                    onToggleDlc: (dlc) {
                      setState(() {
                        final key = dlc.ref.toLowerCase();
                        disabledDlcs.contains(key)
                            ? disabledDlcs.remove(key)
                            : disabledDlcs.add(key);
                      });
                    },
                    onEnableAllDlc: () => setState(disabledDlcs.clear),
                    onAddExtraRoot: _addExtraRoot,
                    onRemoveExtraRoot: _removeExtraRoot,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
