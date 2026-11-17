import 'package:flutter_test/flutter_test.dart';
import 'package:notevalult/app/provider_retry.dart';
import 'package:notevalult/core/errors/failure.dart';

void main() {
  test('network failures retry 3 times with backoff', () {
    expect(
      providerRetry(0, const NetworkFailure()),
      const Duration(milliseconds: 200),
    );
    expect(
      providerRetry(1, const NetworkFailure()),
      const Duration(milliseconds: 400),
    );
    expect(
      providerRetry(2, const NetworkFailure()),
      const Duration(milliseconds: 800),
    );
    expect(providerRetry(3, const NetworkFailure()), isNull);
  });

  test('other failures and programming errors are not retried', () {
    expect(providerRetry(0, const NotFoundFailure()), isNull);
    expect(providerRetry(0, const LocalDatabaseFailure()), isNull);
    expect(providerRetry(0, const AuthFailure()), isNull);
    expect(providerRetry(0, StateError('bug')), isNull);
  });
}
