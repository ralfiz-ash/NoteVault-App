// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// - Android / iOS: a SQLite file in the app's documents directory.
/// - Web: SQLite compiled to WebAssembly (OPFS or IndexedDB storage). Needs
///   `web/sqlite3.wasm` and `web/drift_worker.js`, produced by
///   `tool/build_web_db_assets.sh`.

@ProviderFor(databaseOpener)
final databaseOpenerProvider = DatabaseOpenerProvider._();

/// - Android / iOS: a SQLite file in the app's documents directory.
/// - Web: SQLite compiled to WebAssembly (OPFS or IndexedDB storage). Needs
///   `web/sqlite3.wasm` and `web/drift_worker.js`, produced by
///   `tool/build_web_db_assets.sh`.

final class DatabaseOpenerProvider
    extends $FunctionalProvider<DatabaseOpener, DatabaseOpener, DatabaseOpener>
    with $Provider<DatabaseOpener> {
  /// - Android / iOS: a SQLite file in the app's documents directory.
  /// - Web: SQLite compiled to WebAssembly (OPFS or IndexedDB storage). Needs
  ///   `web/sqlite3.wasm` and `web/drift_worker.js`, produced by
  ///   `tool/build_web_db_assets.sh`.
  DatabaseOpenerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'databaseOpenerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$databaseOpenerHash();

  @$internal
  @override
  $ProviderElement<DatabaseOpener> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DatabaseOpener create(Ref ref) {
    return databaseOpener(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DatabaseOpener value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DatabaseOpener>(value),
    );
  }
}

String _$databaseOpenerHash() => r'13100d3b499af9e8233302e94641ebc6e05f7046';

/// The signed-in user's local database (one database per user, so one user's
/// notes, folders and tags can never be shown to another user of the same
/// device).
///
/// Rebuilt when the user changes: the previous database is closed
/// (`ref.onDispose`) and every data source, repository and provider built on
/// it is rebuilt for the new user. Fails with [AuthFailure] while nobody is
/// signed in (the router keeps signed-out users on the auth screens).
///
/// It is opened lazily on the first query. Tests override this provider (or
/// [databaseOpenerProvider]) with an in-memory database.

@ProviderFor(appDatabase)
final appDatabaseProvider = AppDatabaseProvider._();

/// The signed-in user's local database (one database per user, so one user's
/// notes, folders and tags can never be shown to another user of the same
/// device).
///
/// Rebuilt when the user changes: the previous database is closed
/// (`ref.onDispose`) and every data source, repository and provider built on
/// it is rebuilt for the new user. Fails with [AuthFailure] while nobody is
/// signed in (the router keeps signed-out users on the auth screens).
///
/// It is opened lazily on the first query. Tests override this provider (or
/// [databaseOpenerProvider]) with an in-memory database.

final class AppDatabaseProvider
    extends $FunctionalProvider<AppDatabase, AppDatabase, AppDatabase>
    with $Provider<AppDatabase> {
  /// The signed-in user's local database (one database per user, so one user's
  /// notes, folders and tags can never be shown to another user of the same
  /// device).
  ///
  /// Rebuilt when the user changes: the previous database is closed
  /// (`ref.onDispose`) and every data source, repository and provider built on
  /// it is rebuilt for the new user. Fails with [AuthFailure] while nobody is
  /// signed in (the router keeps signed-out users on the auth screens).
  ///
  /// It is opened lazily on the first query. Tests override this provider (or
  /// [databaseOpenerProvider]) with an in-memory database.
  AppDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appDatabaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appDatabaseHash();

  @$internal
  @override
  $ProviderElement<AppDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppDatabase create(Ref ref) {
    return appDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppDatabase>(value),
    );
  }
}

String _$appDatabaseHash() => r'0b43a7d87cca0107eca1afb57eb018495965b624';

@ProviderFor(localDatabaseExceptionMapper)
final localDatabaseExceptionMapperProvider =
    LocalDatabaseExceptionMapperProvider._();

final class LocalDatabaseExceptionMapperProvider
    extends
        $FunctionalProvider<ExceptionMapper, ExceptionMapper, ExceptionMapper>
    with $Provider<ExceptionMapper> {
  LocalDatabaseExceptionMapperProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localDatabaseExceptionMapperProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localDatabaseExceptionMapperHash();

  @$internal
  @override
  $ProviderElement<ExceptionMapper> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ExceptionMapper create(Ref ref) {
    return localDatabaseExceptionMapper(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExceptionMapper value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExceptionMapper>(value),
    );
  }
}

String _$localDatabaseExceptionMapperHash() =>
    r'1aa96fa0638b4412c04006c7c909e1aaacc98452';

@ProviderFor(clock)
final clockProvider = ClockProvider._();

final class ClockProvider extends $FunctionalProvider<Clock, Clock, Clock>
    with $Provider<Clock> {
  ClockProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clockProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clockHash();

  @$internal
  @override
  $ProviderElement<Clock> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Clock create(Ref ref) {
    return clock(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Clock value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Clock>(value),
    );
  }
}

String _$clockHash() => r'ce4c8073e4878f6859ed9a59fae2c1819b4179af';

@ProviderFor(idGenerator)
final idGeneratorProvider = IdGeneratorProvider._();

final class IdGeneratorProvider
    extends $FunctionalProvider<IdGenerator, IdGenerator, IdGenerator>
    with $Provider<IdGenerator> {
  IdGeneratorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'idGeneratorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$idGeneratorHash();

  @$internal
  @override
  $ProviderElement<IdGenerator> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  IdGenerator create(Ref ref) {
    return idGenerator(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IdGenerator value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IdGenerator>(value),
    );
  }
}

String _$idGeneratorHash() => r'efbf21b17f107fe929908384c9ec689afab46ec0';

/// The signed-in user's persistent sync queue (in their database).

@ProviderFor(syncQueueStore)
final syncQueueStoreProvider = SyncQueueStoreProvider._();

/// The signed-in user's persistent sync queue (in their database).

final class SyncQueueStoreProvider
    extends $FunctionalProvider<SyncQueueStore, SyncQueueStore, SyncQueueStore>
    with $Provider<SyncQueueStore> {
  /// The signed-in user's persistent sync queue (in their database).
  SyncQueueStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncQueueStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncQueueStoreHash();

  @$internal
  @override
  $ProviderElement<SyncQueueStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SyncQueueStore create(Ref ref) {
    return syncQueueStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncQueueStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncQueueStore>(value),
    );
  }
}

String _$syncQueueStoreHash() => r'dec11da28d6b0216b7d0cce430dd27768d7bff05';

/// Makes a local change and its sync record one transaction.

@ProviderFor(localTransactions)
final localTransactionsProvider = LocalTransactionsProvider._();

/// Makes a local change and its sync record one transaction.

final class LocalTransactionsProvider
    extends
        $FunctionalProvider<
          LocalTransactionRunner,
          LocalTransactionRunner,
          LocalTransactionRunner
        >
    with $Provider<LocalTransactionRunner> {
  /// Makes a local change and its sync record one transaction.
  LocalTransactionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localTransactionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localTransactionsHash();

  @$internal
  @override
  $ProviderElement<LocalTransactionRunner> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LocalTransactionRunner create(Ref ref) {
    return localTransactions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocalTransactionRunner value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocalTransactionRunner>(value),
    );
  }
}

String _$localTransactionsHash() => r'3e774ba3c931ae44e4e632468948929b306d6919';
