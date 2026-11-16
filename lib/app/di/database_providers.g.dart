// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The app database. It is opened lazily on the first query, and closed when
/// the container is disposed. Tests override this provider with an in-memory
/// database.
///
/// - Android / iOS: a SQLite file in the app's documents directory.
/// - Web: SQLite compiled to WebAssembly (OPFS or IndexedDB storage). Needs
///   `web/sqlite3.wasm` and `web/drift_worker.js`, produced by
///   `tool/build_web_db_assets.sh`.

@ProviderFor(appDatabase)
final appDatabaseProvider = AppDatabaseProvider._();

/// The app database. It is opened lazily on the first query, and closed when
/// the container is disposed. Tests override this provider with an in-memory
/// database.
///
/// - Android / iOS: a SQLite file in the app's documents directory.
/// - Web: SQLite compiled to WebAssembly (OPFS or IndexedDB storage). Needs
///   `web/sqlite3.wasm` and `web/drift_worker.js`, produced by
///   `tool/build_web_db_assets.sh`.

final class AppDatabaseProvider
    extends $FunctionalProvider<AppDatabase, AppDatabase, AppDatabase>
    with $Provider<AppDatabase> {
  /// The app database. It is opened lazily on the first query, and closed when
  /// the container is disposed. Tests override this provider with an in-memory
  /// database.
  ///
  /// - Android / iOS: a SQLite file in the app's documents directory.
  /// - Web: SQLite compiled to WebAssembly (OPFS or IndexedDB storage). Needs
  ///   `web/sqlite3.wasm` and `web/drift_worker.js`, produced by
  ///   `tool/build_web_db_assets.sh`.
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

String _$appDatabaseHash() => r'50b4a46fcf0dc5b52322c7ce279b2a1206ecc381';

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
