import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../app/di/database_providers.dart';
import '../../../../app/di/session_providers.dart';
import '../../../../app/di/sync_providers.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/connectivity_status.dart';
import '../../domain/entities/sync_entities.dart';
import '../../domain/usecases/sync_usecases.dart';
import '../state/sync_state.dart';
import 'connection_status_provider.dart';

part 'sync_providers.g.dart';

/// Queued local changes for the signed-in user, live from the persistent
/// queue (never a separate counter). None while signed out.
///
/// keepAlive: watched by the sync controller for the whole session.
@Riverpod(keepAlive: true)
Stream<PendingChanges> pendingChanges(Ref ref) {
  final userId = ref.watch(
    currentUserIdProvider.select((session) => session.value),
  );
  if (userId == null) return Stream.value(PendingChanges.none);
  return ObservePendingChanges(ref.watch(syncRepositoryProvider))(
    const NoParams(),
  );
}

/// Applies the signed-in user's cloud changes to the local database for as
/// long as it is listened to. One Firestore listener per user: it is
/// created when a user signs in and cancelled (by Riverpod) when the user
/// signs out or changes. Widgets never see this stream; they keep reading
/// the local notes.
///
/// keepAlive: owned by the sync controller for the whole session.
@Riverpod(keepAlive: true)
Stream<RemoteSyncReport> remoteSync(Ref ref) {
  final userId = ref.watch(
    currentUserIdProvider.select((session) => session.value),
  );
  if (userId == null) return const Stream.empty();
  return ref.watch(syncRepositoryProvider).followRemoteChanges(userId);
}

@Riverpod(keepAlive: true)
SyncPendingChanges syncPendingChangesUseCase(Ref ref) =>
    SyncPendingChanges(ref.watch(syncRepositoryProvider));

/// Delay before syncing new local changes (groups quick successive edits).
@Riverpod(keepAlive: true)
Duration syncAfterChangeDelay(Ref ref) => const Duration(seconds: 2);

/// First retry delay after a failed sync; doubles each time, capped at
/// 5 minutes. Reset by a successful sync.
@Riverpod(keepAlive: true)
Duration syncRetryBaseDelay(Ref ref) => const Duration(seconds: 30);

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
@Riverpod(keepAlive: true)
class SyncController extends _$SyncController {
  Timer? _timer;
  Timer? _retryTimer;
  int _failedRuns = 0;

  @override
  SyncState build() {
    ref.listen(connectionStatusProvider, (previous, next) {
      final now = next.value;
      if (now != ConnectivityStatus.disconnected &&
          previous?.value == ConnectivityStatus.disconnected) {
        _schedule(Duration.zero);
      }
    });
    ref.listen(currentUserIdProvider.select((session) => session.value), (
      previous,
      next,
    ) {
      _failedRuns = 0;
      _retryTimer?.cancel();
      if (next != null) _schedule(Duration.zero);
    }, fireImmediately: true);
    ref.listen(
      pendingChangesProvider.select((changes) => changes.value?.pending ?? 0),
      (previous, next) {
        if (next > (previous ?? 0)) {
          _schedule(ref.read(syncAfterChangeDelayProvider));
        }
      },
    );
    ref.listen(remoteSyncProvider, (_, next) {
      switch (next) {
        case AsyncData(:final value) when value.conflicts > 0:
          state = state.copyWith(conflicts: state.conflicts + value.conflicts);
        case AsyncError():
          // Listener ended (e.g. connection or permission problem): start a
          // fresh one later; the queue keeps local changes safe meanwhile.
          _remoteRestart?.cancel();
          _remoteRestart = Timer(
            ref.read(syncRetryBaseDelayProvider),
            () => ref.invalidate(remoteSyncProvider),
          );
        default:
      }
    });
    ref.onDispose(() {
      _timer?.cancel();
      _retryTimer?.cancel();
      _remoteRestart?.cancel();
    });
    return const SyncState();
  }

  Timer? _remoteRestart;

  void _schedule(Duration delay) {
    _timer?.cancel();
    _timer = Timer(delay, syncNow);
  }

  bool get _offline =>
      ref.read(connectionStatusProvider).value ==
      ConnectivityStatus.disconnected;

  /// Uploads queued changes now (if signed in and online).
  Future<void> syncNow() async {
    _timer?.cancel();
    final userId = ref.read(currentUserIdProvider).value;
    if (userId == null || _offline) return;

    state = state.copyWith(phase: SyncPhase.syncing);
    final report = await ref.read(syncPendingChangesUseCaseProvider)(userId);
    if (!ref.mounted) return;

    if (report.conflicts > 0) {
      state = state.copyWith(conflicts: state.conflicts + report.conflicts);
    }
    if (report.hasFailures) {
      state = state.copyWith(
        phase: SyncPhase.failed,
        errorMessage: () =>
            report.error?.message ?? 'Some changes could not be synced.',
      );
      _scheduleRetry();
    } else {
      _failedRuns = 0;
      _retryTimer?.cancel();
      state = state.copyWith(
        phase: SyncPhase.synced,
        lastSyncedAt: ref.read(clockProvider)().toUtc(),
        errorMessage: () => null,
      );
    }
  }

  void _scheduleRetry() {
    _retryTimer?.cancel();
    final base = ref.read(syncRetryBaseDelayProvider);
    final delay = base * pow(2, min(_failedRuns, 4)).toInt();
    const cap = Duration(minutes: 5);
    _failedRuns++;
    _retryTimer = Timer(delay > cap ? cap : delay, syncNow);
  }
}
