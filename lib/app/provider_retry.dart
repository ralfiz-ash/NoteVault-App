import 'package:flutter_riverpod/misc.dart' show ProviderException;

import '../core/errors/failure.dart';

/// App-wide retry policy for failed providers (Riverpod 3 retries every
/// failing provider by default, up to 10 times).
///
/// Only transient problems are retried automatically: a [NetworkFailure], at
/// most 3 times with exponential backoff (200 ms, 400 ms, 800 ms). Everything
/// else (not found, validation, auth, database errors, ...) fails at once so
/// the UI can show the error and offer Retry (`ref.invalidate`). Errors coming
/// from a dependency ([ProviderException]) are retried by that dependency.
Duration? providerRetry(int retryCount, Object error) {
  if (retryCount >= 3) return null;
  if (error is ProviderException || error is Error) return null;
  if (error is NetworkFailure) {
    return const Duration(milliseconds: 200) * (1 << retryCount);
  }
  return null;
}
