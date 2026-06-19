import 'dart:convert';
import 'dart:io';

class DescriptorService {
  static Map<String, String> parseDescriptorFile(String path) {
    try {
      return parseDescriptor(File(path).readAsStringSync(encoding: utf8));
    } catch (_) {
      return {};
    }
  }

  static Map<String, String> parseDescriptor(String text) {
    final data = <String, String>{};
    final pattern = RegExp(
      r'^\s*([A-Za-z0-9_]+)\s*=\s*(?:"([^"]*)"|([^\s#\r\n]+)|\{[\s\S]*?\})',
      multiLine: true,
    );
    for (final match in pattern.allMatches(text)) {
      data[match.group(1)!] = match.group(2) ?? match.group(3) ?? '';
    }
    return data;
  }

  static String descriptorText({
    required String name,
    required String pathValue,
    required String supportedVersion,
    required String version,
    String? remoteFileId,
  }) {
    final lines = [
      'name=${_quote(name)}',
      'version=${_quote(version)}',
      'tags={',
      '\t"Utilities"',
      '}',
      'supported_version=${_quote(supportedVersion.isEmpty ? '*' : supportedVersion)}',
      'path=${_quote(pathValue)}',
    ];
    if (remoteFileId != null && remoteFileId.isNotEmpty) {
      lines.add('remote_file_id=${_quote(remoteFileId)}');
    }
    return '${lines.join('\n')}\n';
  }

  static String _quote(String value) {
    return '"${value.replaceAll('\\', '\\\\').replaceAll('"', r'\"')}"';
  }
}
