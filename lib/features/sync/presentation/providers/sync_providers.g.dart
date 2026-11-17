// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Queued local changes for the signed-in user, live from the persistent
/// queue (never a separate counter). None while signed out.
///
/// keepAlive: watched by the sync controller for the whole session.

@ProviderFor(pendingChanges)
final pendingChangesProvider = PendingChangesProvider._();

/// Queued local changes for the signed-in user, live from the persistent
/// queue (never a separate counter). None while signed out.
///
/// keepAlive: watched by the sync controller for the whole session.

final class PendingChangesProvider
    extends
        $FunctionalProvider<
          AsyncValue<PendingChanges>,
          PendingChanges,
          Stream<PendingChanges>
        >
    with $FutureModifier<PendingChanges>, $StreamProvider<PendingChanges> {
  /// Queued local changes for the signed-in user, live from the persistent
  /// queue (never a separate counter). None while signed out.
  ///
  /// keepAlive: watched by the sync controller for the whole session.
  PendingChangesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingChangesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingChangesHash();

  @$internal
  @override
  $StreamProviderElement<PendingChanges> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<PendingChanges> create(Ref ref) {
    return pendingChanges(ref);
  }
}

String _$pendingChangesHash() => r'f56c1ae3511abce10ae40f581c912bbd905ecc42';

/// Applies the signed-in user's cloud changes to the local database for as
/// long as it is listened to. One Firestore listener per user: it is
/// created when a user signs in and cancelled (by Riverpod) when the user
/// signs out or changes. Widgets never see this stream; they keep reading
/// the local notes.
///
/// keepAlive: owned by the sync controller for the whole session.

@ProviderFor(remoteSync)
final remoteSyncProvider = RemoteSyncProvider._();

/// Applies the signed-in user's cloud changes to the local database for as
/// long as it is listened to. One Firestore listener per user: it is
/// created when a user signs in and cancelled (by Riverpod) when the user
/// signs out or changes. Widgets never see this stream; they keep reading
/// the local notes.
///
/// keepAlive: owned by the sync controller for the whole session.

final class RemoteSyncProvider
    extends
        $FunctionalProvider<
          AsyncValue<RemoteSyncReport>,
          RemoteSyncReport,
          Stream<RemoteSyncReport>
        >
    with $FutureModifier<RemoteSyncReport>, $StreamProvider<RemoteSyncReport> {
  /// Applies the signed-in user's cloud changes to the local database for as
  /// long as it is listened to. One Firestore listener per user: it is
  /// created when a user signs in and cancelled (by Riverpod) when the user
  /// signs out or changes. Widgets never see this stream; they keep reading
  /// the local notes.
  ///
  /// keepAlive: owned by the sync controller for the whole session.
  RemoteSyncProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'remoteSyncProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$remoteSyncHash();

  @$internal
  @override
  $StreamProviderElement<RemoteSyncReport> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<RemoteSyncReport> create(Ref ref) {
    return remoteSync(ref);
  }
}

String _$remoteSyncHash() => r'057f1383c0a3153ca4c10c9ba36e83be5321daaf';

@ProviderFor(syncPendingChangesUseCase)
final syncPendingChangesUseCaseProvider = SyncPendingChangesUseCaseProvider._();

final class SyncPendingChangesUseCaseProvider
    extends
        $FunctionalProvider<
          SyncPendingChanges,
          SyncPendingChanges,
          SyncPendingChanges
        >
    with $Provider<SyncPendingChanges> {
  SyncPendingChangesUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncPendingChangesUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncPendingChangesUseCaseHash();

  @$internal
  @override
  $ProviderElement<SyncPendingChanges> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SyncPendingChanges create(Ref ref) {
    return syncPendingChangesUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncPendingChanges value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncPendingChanges>(value),
    );
  }
}

String _$syncPendingChangesUseCaseHash() =>
    r'a0fad4052235bbc7faa79fe180655508448fd8b3';

/// Delay before syncing new local changes (groups quick successive edits).

@ProviderFor(syncAfterChangeDelay)
final syncAfterChangeDelayProvider = SyncAfterChangeDelayProvider._();

/// Delay before syncing new local changes (groups quick successive edits).

final class SyncAfterChangeDelayProvider
    extends $FunctionalProvider<Duration, Duration, Duration>
    with $Provider<Duration> {
  /// Delay before syncing new local changes (groups quick successive edits).
  SyncAfterChangeDelayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncAfterChangeDelayProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncAfterChangeDelayHash();

  @$internal
  @override
  $ProviderElement<Duration> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Duration create(Ref ref) {
    return syncAfterChangeDelay(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Duration value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Duration>(value),
    );
  }
}

String _$syncAfterChangeDelayHash() =>
    r'25e1743c1e4ae7457a4378d93a661e2a83e1674a';

/// First retry delay after a failed sync; doubles each time, capped at
/// 5 minutes. Reset by a successful sync.

@ProviderFor(syncRetryBaseDelay)
final syncRetryBaseDelayProvider = SyncRetryBaseDelayProvider._();

/// First retry delay after a failed sync; doubles each time, capped at
/// 5 minutes. Reset by a successful sync.

final class SyncRetryBaseDelayProvider
    extends $FunctionalProvider<Duration, Duration, Duration>
    with $Provider<Duration> {
  /// First retry delay after a failed sync; doubles each time, capped at
  /// 5 minutes. Reset by a successful sync.
  SyncRetryBaseDelayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncRetryBaseDelayProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncRetryBaseDelayHash();

  @$internal
  @override
  $ProviderElement<Duration> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Duration create(Ref ref) {
    return syncRetryBaseDelay(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Duration value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Duration>(value),
    );
  }
}

String _$syncRetryBaseDelayHash() =>
    r'f75ea461937b1399378b7fe6d4ec6061d197dad9';

/// Starts uploads at the right moments; no widget ever syncs by itself.
///
/// Triggers (each only schedules a run; runs never overlap because the sync
/// repository shares a running sync):
/// - a user is signed in / the app starts with a restored session
/// - the network comes back (offline -> online)
/// - new local changes are queued (after a short delay)
/// - a failed sync, retried with growing delays (30 s, 1, 2, 4, 5 min)
/// - [syncNow], e.g. the Retry button
///
/// It also keeps the cloud -> device direction ([remoteSyncProvider]) alive
/// and restarts it after an error.
///
/// Nothing is attempted while offline. Built once (keepAlive) and only
/// listens to its inputs, so rebuilding widgets never starts a sync.

@ProviderFor(SyncController)
final syncControllerProvider = SyncControllerProvider._();

/// Starts uploads at the right moments; no widget ever syncs by itself.
///
/// Triggers (each only schedules a run; runs never overlap because the sync
/// repository shares a running sync):
/// - a user is signed in / the app starts with a restored session
/// - the network comes back (offline -> online)
/// - new local changes are queued (after a short delay)
/// - a failed sync, retried with growing delays (30 s, 1, 2, 4, 5 min)
/// - [syncNow], e.g. the Retry button
///
/// It also keeps the cloud -> device direction ([remoteSyncProvider]) alive
/// and restarts it after an error.
///
/// Nothing is attempted while offline. Built once (keepAlive) and only
/// listens to its inputs, so rebuilding widgets never starts a sync.
final class SyncControllerProvider
    extends $NotifierProvider<SyncController, SyncState> {
  /// Starts uploads at the right moments; no widget ever syncs by itself.
  ///
  /// Triggers (each only schedules a run; runs never overlap because the sync
  /// repository shares a running sync):
  /// - a user is signed in / the app starts with a restored session
  /// - the network comes back (offline -> online)
  /// - new local changes are queued (after a short delay)
  /// - a failed sync, retried with growing delays (30 s, 1, 2, 4, 5 min)
  /// - [syncNow], e.g. the Retry button
  ///
  /// It also keeps the cloud -> device direction ([remoteSyncProvider]) alive
  /// and restarts it after an error.
  ///
  /// Nothing is attempted while offline. Built once (keepAlive) and only
  /// listens to its inputs, so rebuilding widgets never starts a sync.
  SyncControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncControllerHash();

  @$internal
  @override
  SyncController create() => SyncController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncState>(value),
    );
  }
}

String _$syncControllerHash() => r'1c102853a1358b3ddf43f1036807f90927e44527';

/// Starts uploads at the right moments; no widget ever syncs by itself.
///
/// Triggers (each only schedules a run; runs never overlap because the sync
/// repository shares a running sync):
/// - a user is signed in / the app starts with a restored session
/// - the network comes back (offline -> online)
/// - new local changes are queued (after a short delay)
/// - a failed sync, retried with growing delays (30 s, 1, 2, 4, 5 min)
/// - [syncNow], e.g. the Retry button
///
/// It also keeps the cloud -> device direction ([remoteSyncProvider]) alive
/// and restarts it after an error.
///
/// Nothing is attempted while offline. Built once (keepAlive) and only
/// listens to its inputs, so rebuilding widgets never starts a sync.

abstract class _$SyncController extends $Notifier<SyncState> {
  SyncState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SyncState, SyncState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SyncState, SyncState>,
              SyncState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
