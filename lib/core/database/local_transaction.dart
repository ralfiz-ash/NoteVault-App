import 'app_database.dart';

/// Runs several local writes as one all-or-nothing unit (e.g. "save the note
/// AND record it for sync"). Data sources called inside [run] join the same
/// transaction.
abstract interface class LocalTransactionRunner {
  Future<T> run<T>(Future<T> Function() action);
}

class DriftTransactionRunner implements LocalTransactionRunner {
  const DriftTransactionRunner(this._db);

  final AppDatabase _db;

  @override
  Future<T> run<T>(Future<T> Function() action) => _db.transaction(action);
}

/// For code paths that need no atomicity (and tests).
class NoTransactionRunner implements LocalTransactionRunner {
  const NoTransactionRunner();

  @override
  Future<T> run<T>(Future<T> Function() action) => action();
}
