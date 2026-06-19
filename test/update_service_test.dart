import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:vic3_mod_launcher/services/update_service.dart';

void main() {
  test('reads update manifest from a Windows drive path', () async {
    PackageInfo.setMockInitialValues(
      appName: 'Victoria 3 Mod Launcher',
      packageName: 'vic3_mod_launcher',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
      installerStore: null,
    );

    final dir = Directory.systemTemp.createTempSync('vic3_update_test_');
    addTearDown(() => dir.deleteSync(recursive: true));

    final installer = File('${dir.path}${Platform.pathSeparator}setup.exe')
      ..writeAsBytesSync([1, 2, 3]);
    final manifest = File('${dir.path}${Platform.pathSeparator}latest.json')
      ..writeAsStringSync('''
{
  "version": "999.0.0",
  "buildNumber": 1,
  "installerUrl": "${installer.path.replaceAll(r'\', r'\\')}",
  "sha256": "",
  "notes": "test"
}
''');

    final result = await const UpdateService().check(manifest.path);

    expect(result.latest.version, '999.0.0');
    expect(result.latest.installerUrl, installer.path);
  });
}
