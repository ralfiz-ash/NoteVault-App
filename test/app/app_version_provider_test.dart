import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notevalult/app/di/app_info_providers.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  test('appVersion is the installed version name from the platform', () async {
    PackageInfo.setMockInitialValues(
      appName: 'NoteVault',
      packageName: 'com.ashiq.notevalult',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(await container.read(appVersionProvider.future), '1.0.0');
  });
}
