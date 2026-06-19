import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;

import '../models.dart';

class UpdateService {
  const UpdateService();

  Future<AppVersion> currentVersion() async {
    final info = await PackageInfo.fromPlatform();
    return AppVersion(
      version: info.version,
      buildNumber: int.tryParse(info.buildNumber) ?? 0,
    );
  }

  Future<UpdateCheckResult> check(String manifestLocation) async {
    final current = await currentVersion();
    final manifest = await _readText(manifestLocation);
    final data = jsonDecode(manifest) as Map<String, dynamic>;
    final latest = UpdateInfo(
      version: data['version']?.toString().trim() ?? '',
      buildNumber: int.tryParse(data['buildNumber']?.toString() ?? '') ?? 0,
      installerUrl: data['installerUrl']?.toString().trim() ?? '',
      sha256: data['sha256']?.toString().trim().toLowerCase() ?? '',
      notes: data['notes']?.toString().trim() ?? '',
      publishedAt: DateTime.tryParse(data['publishedAt']?.toString() ?? ''),
    );
    if (latest.version.isEmpty || latest.installerUrl.isEmpty) {
      throw const FormatException(
        'Update manifest must contain version and installerUrl.',
      );
    }
    return UpdateCheckResult(
      current: current,
      latest: latest,
      updateAvailable:
          _compareVersion(
            latest.version,
            latest.buildNumber,
            current.version,
            current.buildNumber,
          ) >
          0,
    );
  }

  Future<File> downloadInstaller(
    UpdateInfo update, {
    required void Function(int received, int? total) onProgress,
  }) async {
    final tempDir = await Directory.systemTemp.createTemp('vic3_update_');
    final target = File(p.join(tempDir.path, 'Vic3ModLauncher-Setup.exe'));
    final source = update.installerUrl.trim();
    final uri = Uri.tryParse(source);

    if (uri == null || uri.scheme.isEmpty || uri.scheme == 'file') {
      final sourceFile = File(
        uri?.scheme == 'file' ? uri!.toFilePath() : source,
      );
      if (!sourceFile.existsSync()) {
        throw Exception('Installer file not found: ${sourceFile.path}');
      }
      final total = sourceFile.lengthSync();
      var received = 0;
      final input = sourceFile.openRead();
      final output = target.openWrite();
      await for (final chunk in input) {
        received += chunk.length;
        output.add(chunk);
        onProgress(received, total);
      }
      await output.close();
    } else if (uri.scheme == 'http' || uri.scheme == 'https') {
      final client = HttpClient();
      try {
        final request = await client.getUrl(uri);
        final response = await request.close();
        if (response.statusCode < 200 || response.statusCode >= 300) {
          throw HttpException(
            'Download failed with HTTP ${response.statusCode}',
            uri: uri,
          );
        }
        final total = response.contentLength >= 0
            ? response.contentLength
            : null;
        var received = 0;
        final output = target.openWrite();
        await for (final chunk in response) {
          received += chunk.length;
          output.add(chunk);
          onProgress(received, total);
        }
        await output.close();
      } finally {
        client.close(force: true);
      }
    } else {
      throw UnsupportedError('Unsupported installer URL: $source');
    }

    if (update.sha256.isNotEmpty) {
      final digest = await sha256.bind(target.openRead()).first;
      if (digest.toString().toLowerCase() != update.sha256) {
        throw Exception(
          'Downloaded installer SHA256 mismatch.\nExpected: ${update.sha256}\nActual: $digest',
        );
      }
    }

    return target;
  }

  Future<void> launchInstaller(File installer) async {
    if (!Platform.isWindows) {
      await Process.start(
        installer.path,
        const [],
        mode: ProcessStartMode.detached,
      );
      return;
    }

    await Process.start(
      'powershell',
      [
        '-NoProfile',
        '-ExecutionPolicy',
        'Bypass',
        '-Command',
        'Start-Process -FilePath \$env:VIC3_INSTALLER',
      ],
      environment: {'VIC3_INSTALLER': installer.path},
      mode: ProcessStartMode.detached,
    );
  }

  Future<String> _readText(String location) async {
    final value = location.trim();
    if (value.isEmpty) {
      throw const FormatException('Update manifest URL is empty.');
    }

    final uri = Uri.tryParse(value);
    if (uri == null || uri.scheme.isEmpty || uri.scheme == 'file') {
      final file = File(uri?.scheme == 'file' ? uri!.toFilePath() : value);
      if (!file.existsSync()) throw Exception('Manifest not found: $value');
      return file.readAsString();
    }

    if (uri.scheme != 'http' && uri.scheme != 'https') {
      throw UnsupportedError('Unsupported manifest URL: $value');
    }

    final client = HttpClient();
    try {
      final request = await client.getUrl(uri);
      final response = await request.close();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException(
          'Manifest request failed with HTTP ${response.statusCode}',
          uri: uri,
        );
      }
      return utf8.decode(await response.expand((chunk) => chunk).toList());
    } finally {
      client.close(force: true);
    }
  }

  int _compareVersion(
    String leftVersion,
    int leftBuild,
    String rightVersion,
    int rightBuild,
  ) {
    final left = _versionParts(leftVersion);
    final right = _versionParts(rightVersion);
    final length = left.length > right.length ? left.length : right.length;
    for (var i = 0; i < length; i++) {
      final diff =
          (i < left.length ? left[i] : 0) - (i < right.length ? right[i] : 0);
      if (diff != 0) return diff;
    }
    return leftBuild - rightBuild;
  }

  List<int> _versionParts(String version) {
    return version
        .split(RegExp(r'[^0-9]+'))
        .where((part) => part.isNotEmpty)
        .map((part) => int.tryParse(part) ?? 0)
        .toList();
  }
}
