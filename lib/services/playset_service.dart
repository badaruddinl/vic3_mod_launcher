import 'dart:io';

import 'package:path/path.dart' as p;

import '../models.dart';
import 'json_service.dart';
import 'path_service.dart';

class PlaysetService {
  const PlaysetService();

  String get directory {
    return p.join(p.dirname(PathService.configPath()), 'playsets');
  }

  List<SavedPlayset> list() {
    final dir = Directory(directory);
    if (!dir.existsSync()) return const [];
    final items = <SavedPlayset>[];
    for (final file in dir.listSync().whereType<File>()) {
      if (!file.path.toLowerCase().endsWith('.json')) continue;
      final data = readJsonMap(file.path);
      final name = data['name']?.toString().trim();
      items.add(
        SavedPlayset(
          name: name?.isNotEmpty == true
              ? name!
              : p.basenameWithoutExtension(file.path),
          path: file.path,
          modifiedAt: file.lastModifiedSync(),
        ),
      );
    }
    items.sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
    return items;
  }

  void save({
    required String name,
    required List<Map<String, String>> enabledMods,
    required List<Map<String, String>> disabledDlc,
  }) {
    final cleanName = PathService.safeName(name);
    final path = p.join(directory, '$cleanName.json');
    writePrettyJson(path, {
      'name': name.trim().isEmpty ? cleanName : name.trim(),
      'enabledMods': enabledMods,
      'orderedListMods': enabledMods,
      'disabledDLC': disabledDlc,
      'enabledUGC': [],
    });
  }

  Map<String, dynamic> load(SavedPlayset playset) {
    return readJsonMap(playset.path);
  }

  void delete(SavedPlayset playset) {
    final file = File(playset.path);
    if (file.existsSync()) file.deleteSync();
  }
}
