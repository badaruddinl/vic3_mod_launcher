import 'dart:io';

import 'package:path/path.dart' as p;

import '../models.dart';
import 'descriptor_service.dart';
import 'path_service.dart';

class DlcLibraryService {
  const DlcLibraryService();

  List<DlcInfo> scan(String gameRoot) {
    final dlcs = <DlcInfo>[];
    final root = Directory(gameRoot);
    if (!root.existsSync()) return dlcs;
    final candidates = [
      Directory(p.join(root.path, 'game', 'dlc')),
      Directory(p.join(root.path, 'dlc')),
    ];
    for (final base in candidates) {
      if (!base.existsSync()) continue;
      for (final file in base.listSync(recursive: true).whereType<File>()) {
        if (!file.path.toLowerCase().endsWith('.dlc')) continue;
        final data = DescriptorService.parseDescriptorFile(file.path);
        final ref = PathService.relativeDlcRef(file.path, gameRoot);
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
    return dlcs;
  }
}
