import 'dart:convert';
import 'dart:io';

Map<String, dynamic> readJsonMap(String path) {
  try {
    return jsonDecode(File(path).readAsStringSync(encoding: utf8))
        as Map<String, dynamic>;
  } catch (_) {
    return <String, dynamic>{};
  }
}

void writePrettyJson(String path, Map<String, dynamic> data) {
  final file = File(path)..parent.createSync(recursive: true);
  file.writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(data),
    encoding: utf8,
  );
}
