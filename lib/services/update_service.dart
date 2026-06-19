import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;

import '../models.dart';
import 'app_logger.dart';

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
    AppLogger.info('Update check started. Manifest: $manifestLocation');
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
    final result = UpdateCheckResult(
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
    AppLogger.info(
      'Update check completed. Current: ${current.label}, latest: ${latest.label}, available: ${result.updateAvailable}',
    );
    return result;
  }

  Future<File> downloadInstaller(
    UpdateInfo update, {
    required void Function(int received, int? total) onProgress,
  }) async {
    final tempDir = await Directory.systemTemp.createTemp('vic3_update_');
    final target = File(p.join(tempDir.path, 'Vic3ModLauncher-Setup.exe'));
    final source = update.installerUrl.trim();
    final uri = Uri.tryParse(source);
    AppLogger.info(
      'Update download started. Version: ${update.label}, source: $source, target: ${target.path}',
    );

    if (_isLocalFileLocation(source, uri)) {
      final sourceFile = File(_localFilePath(source, uri));
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
    } else if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
      final client = HttpClient();
      try {
        final request = await client.getUrl(_withCacheBust(uri));
        final response = await request.close();
        if (response.statusCode < 200 || response.statusCode >= 300) {
          throw _httpUpdateException(
            'Installer download failed',
            response.statusCode,
            uri,
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
      AppLogger.info('Verifying update installer SHA256.');
      final digest = await sha256.bind(target.openRead()).first;
      if (digest.toString().toLowerCase() != update.sha256) {
        throw Exception(
          'Downloaded installer SHA256 mismatch.\nExpected: ${update.sha256}\nActual: $digest',
        );
      }
      AppLogger.info('Update installer SHA256 verified: $digest');
    }

    AppLogger.info('Update download completed: ${target.path}');
    return target;
  }

  Future<void> launchInstaller(File installer) async {
    const args = [
      '/SP-',
      '/VERYSILENT',
      '/SUPPRESSMSGBOXES',
      '/NORESTART',
      '/CLOSEAPPLICATIONS',
      '/FORCECLOSEAPPLICATIONS',
    ];
    AppLogger.info(
      'Launching update installer: ${installer.path} ${args.join(' ')}',
    );
    await Process.start(
      installer.path,
      args,
      runInShell: Platform.isWindows,
      mode: ProcessStartMode.detached,
    );
  }

  Future<String> _readText(String location) async {
    final value = location.trim();
    if (value.isEmpty) {
      throw const FormatException('Update manifest URL is empty.');
    }

    final uri = Uri.tryParse(value);
    if (_isLocalFileLocation(value, uri)) {
      final file = File(_localFilePath(value, uri));
      if (!file.existsSync()) throw Exception('Manifest not found: $value');
      return file.readAsString();
    }

    if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
      throw UnsupportedError('Unsupported manifest URL: $value');
    }

    final client = HttpClient();
    try {
      final request = await client.getUrl(_withCacheBust(uri));
      final response = await request.close();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw _httpUpdateException(
          'Manifest request failed',
          response.statusCode,
          uri,
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

  bool _isLocalFileLocation(String value, Uri? uri) {
    if (uri == null || uri.scheme.isEmpty || uri.scheme == 'file') return true;
    if (Platform.isWindows && RegExp(r'^[a-zA-Z]:[\\/]').hasMatch(value)) {
      return true;
    }
    if (value.startsWith(r'\\')) return true;
    return false;
  }

  String _localFilePath(String value, Uri? uri) {
    if (uri != null && uri.scheme == 'file') return uri.toFilePath();
    return value;
  }

  Uri _withCacheBust(Uri uri) {
    final updated = Map<String, String>.from(uri.queryParameters);
    updated['_'] = DateTime.now().millisecondsSinceEpoch.toString();
    return uri.replace(queryParameters: updated);
  }

  HttpException _httpUpdateException(String action, int statusCode, Uri uri) {
    final githubReleaseAsset =
        uri.host.equalsIgnoreCase('github.com') &&
        uri.path.contains('/releases/');
    final hint = statusCode == 404 && githubReleaseAsset
        ? '\n\nIf this is a GitHub Release URL, make sure the release asset exists and the repository/release is public. Private GitHub release assets return 404 to this app because it does not use a GitHub token.\n\nFor local testing, set Update Source to dist/latest.local-test.json.'
        : '';
    return HttpException('$action with HTTP $statusCode.$hint', uri: uri);
  }
}

extension _CaseInsensitiveString on String {
  bool equalsIgnoreCase(String other) => toLowerCase() == other.toLowerCase();
}
