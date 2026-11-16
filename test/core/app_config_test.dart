import 'package:flutter_test/flutter_test.dart';
import 'package:notevalult/core/config/app_config.dart';
import 'package:notevalult/core/logging/app_logger.dart';

void main() {
  test('environment parsing is case-insensitive and defaults to dev', () {
    expect(AppEnvironment.parse('PROD'), AppEnvironment.prod);
    expect(AppEnvironment.parse('staging'), AppEnvironment.staging);
    expect(AppEnvironment.parse('nonsense'), AppEnvironment.dev);
  });

  test('production logs warnings and above only', () {
    expect(
      const AppConfig(environment: AppEnvironment.prod).minLogLevel,
      LogLevel.warning,
    );
    expect(const AppConfig().minLogLevel, LogLevel.debug);
  });

  test('fromEnvironment defaults to dev without --dart-define', () {
    expect(AppConfig.fromEnvironment().environment, AppEnvironment.dev);
  });
}
