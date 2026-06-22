import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;

import '../models.dart';
import 'descriptor_service.dart';
import 'launcher_config.dart';
import 'path_service.dart';

class ModLibraryService {
  const ModLibraryService({required this.config, required this.gameVersion});

  final LauncherConfig config;
  final String gameVersion;

  Future<Map<String, ModInfo>> scan() async {
    final result = <String, ModInfo>{};
    final modDir = Directory(config.modPath);

    for (final file in modDir.listSync().whereType<File>()) {
      if (!file.path.toLowerCase().endsWith('.mod')) continue;
      final info = modFromDescriptor(file);
      if (info != null) result[info.id] = info;
    }

    for (final dir in modDir.listSync().whereType<Directory>()) {
      final descriptor = File(p.join(dir.path, 'descriptor.mod'));
      final hasKnownMod = result.values.any(
        (mod) => PathService.samePath(mod.contentPath, dir.path),
      );
      if (!hasKnownMod && (descriptor.existsSync() || config.autoRepair)) {
        final modFile = ensureModFileForFolder(dir.path, localFolder: true);
        final info = modFromDescriptor(File(modFile));
        if (info != null) result[info.id] = info;
      }
    }

    for (final rootPath in config.extraModRoots) {
      final root = Directory(rootPath);
      if (!root.existsSync()) continue;
      for (final dir in root.listSync().whereType<Directory>()) {
        final descriptor = File(p.join(dir.path, 'descriptor.mod'));
        if (!descriptor.existsSync()) continue;
        final modFile = ensureModFileForFolder(dir.path, localFolder: false);
        final info = modFromDescriptor(File(modFile));
        if (info != null) result[info.id] = info;
      }
    }

    return result;
  }

  ModInfo? modFromDescriptor(File modFile) {
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
    final iconPath = _resolveIconPath(
      descriptorData: data,
      contentPath: contentPath,
      modFilePath: modFile.path,
    );
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
      iconPath: iconPath,
    );
  }

  String _resolveIconPath({
    required Map<String, String> descriptorData,
    required String contentPath,
    required String modFilePath,
  }) {
    final candidates = <String>[];
    void addCandidate(String value, {String? basePath}) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return;
      if (p.isAbsolute(trimmed)) {
        candidates.add(trimmed);
      } else if (basePath != null && basePath.isNotEmpty) {
        candidates.add(p.join(basePath, trimmed));
      }
    }

    addCandidate(descriptorData['picture'] ?? '', basePath: contentPath);
    addCandidate(
      descriptorData['picture'] ?? '',
      basePath: p.dirname(modFilePath),
    );

    final descriptor = File(p.join(contentPath, 'descriptor.mod'));
    if (descriptor.existsSync()) {
      final contentDescriptor = DescriptorService.parseDescriptorFile(
        descriptor.path,
      );
      addCandidate(contentDescriptor['picture'] ?? '', basePath: contentPath);
    }

    for (final name in const [
      'thumbnail.png',
      'thumbnail.jpg',
      'thumbnail.jpeg',
      'preview.png',
      'preview.jpg',
      'preview.jpeg',
      'icon.png',
      'icon.jpg',
      'icon.jpeg',
    ]) {
      addCandidate(name, basePath: contentPath);
    }

    for (final candidate in candidates) {
      final file = File(candidate);
      if (file.existsSync()) return file.path;
    }
    return '';
  }

  String ensureModFileForFolder(
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
    final existing = findExistingModForFolder(folder.path);
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

  String? findExistingModForFolder(String folderPath) {
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

  int repairDescriptors() {
    final modDir = Directory(config.modPath)..createSync(recursive: true);
    final before = _modDescriptorCount(modDir);

    for (final dir in modDir.listSync().whereType<Directory>()) {
      ensureModFileForFolder(dir.path, localFolder: true);
    }

    for (final rootPath in config.extraModRoots) {
      final root = Directory(rootPath);
      if (!root.existsSync()) continue;
      for (final dir in root.listSync().whereType<Directory>()) {
        if (File(p.join(dir.path, 'descriptor.mod')).existsSync()) {
          ensureModFileForFolder(dir.path, localFolder: false);
        }
      }
    }

    final created = _modDescriptorCount(modDir) - before;
    return created < 0 ? 0 : created;
  }

  void extractZipMod(String zipPath) {
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
    ensureModFileForFolder(target.path, localFolder: true);
  }

  int _modDescriptorCount(Directory modDir) {
    return modDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.toLowerCase().endsWith('.mod'))
        .length;
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
}
