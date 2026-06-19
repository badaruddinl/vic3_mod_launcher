import 'package:flutter_test/flutter_test.dart';
import 'package:vic3_mod_launcher/models.dart';
import 'package:vic3_mod_launcher/services/path_service.dart';

void main() {
  test('parses Victoria 3 versions and wildcard compatibility', () {
    expect(PathService.parseVersion('Victoria 3 1.7.6'), '1.7.6');
    expect(PathService.parseVersion('release/1.13.8'), '1.13.8');
    expect(PathService.parseVersion('v1.13.8.xxh128'), '1.13.8');
    expect(PathService.wildcardVersion('1.7.6'), '1.7.*');
    expect(PathService.versionCompatible('1.7.6', '1.7.*'), VersionStatus.ok);
    expect(
      PathService.versionCompatible('1.7.6', '1.6.*'),
      VersionStatus.warning,
    );
  });
}
