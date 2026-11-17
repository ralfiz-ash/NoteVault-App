import '../../../../core/database/sync_queue_store.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../notes/domain/repositories/note_remote_repository.dart';
import '../../../notes/domain/repositories/note_repository.dart';
import '../../domain/entities/sync_entities.dart';
import '../../domain/repositories/sync_repository.dart';

/// Processes the persistent sync queue.
///
/// For each queued note: claim it (pending/failed -> syncing, guarded by its
/// version), upload the CURRENT local note (or delete the cloud copy), then
/// remove it from the queue. If the note changed again during the upload,
/// the row stays pending and the newer state goes up next. Failures keep the
/// row (failed, with retry count and error); local data is never touched.
class SyncRepositoryImpl implements SyncRepository {
  SyncRepositoryImpl({
    required this.queue,
    required this.localNotes,
    required this.remoteNotes,
    this.logger = const NoOpLogger(),
  });

  final SyncQueueStore queue;
  final NoteRepository localNotes;
  final NoteRemoteRepository remoteNotes;
  final AppLogger logger;

  Future<SyncReport>? _running;
  bool _runAgain = false;

  @override
  Stream<PendingChanges> watchPendingChanges() => queue.watchCounts().map(
    (c) => PendingChanges(
      pending: c.pending,
      failed: c.failed,
      lastError: c.lastError,
    ),
  );

  @override
  Future<SyncReport> syncPendingChanges(String userId) {
    final running = _running;
    if (running != null) {
      // Single flight: share the current run, then run once more for
      // anything queued meanwhile.
      _runAgain = true;
      return running;
    }
    final run = _runUntilSettled(userId);
    _running = run;
    return run.whenComplete(() => _running = null);
  }

  Future<SyncReport> _runUntilSettled(String userId) async {
    var report = const SyncReport();
    do {
      _runAgain = false;
      final pass = await _runOnce(userId);
      report = report + pass;
      // Offline/auth problems: stop; the next trigger retries.
      if (pass.error is NetworkFailure || pass.error is AuthFailure) break;
    } while (_runAgain);
    return report;
  }

  Future<SyncReport> _runOnce(String userId) async {
    var synced = 0;
    var failed = 0;
    Failure? firstError;
    try {
      await queue.releaseInterrupted();
      for (final entry in await queue.due()) {
        if (entry.entityType != SyncEntity.note) continue;
        if (!await queue.claim(entry)) continue; // changed or taken
        try {
          await _push(userId, entry);
          await queue.complete(entry);
          synced++;
        } on Failure catch (failure) {
          await queue.fail(entry, failure.message);
          failed++;
          firstError ??= failure;
          logger.warning(
            'Sync of a note failed',
            data: {'operation': entry.operation.name},
            error: failure,
          );
          if (failure is NetworkFailure || failure is AuthFailure) break;
        }
      }
    } on Object catch (error, stackTrace) {
      // Local queue problem: nothing is lost (rows stay), report it.
      logger.error('Sync run failed', error: error, stackTrace: stackTrace);
      firstError ??= error is Failure
          ? error
          : UnknownFailure(cause: error, stackTrace: stackTrace);
    }
    return SyncReport(synced: synced, failed: failed, error: firstError);
  }

  Future<void> _push(String userId, SyncQueueEntry entry) async {
    if (entry.operation == SyncOperation.delete) {
      return remoteNotes.deleteNoteIfExists(userId, entry.entityId);
    }
    try {
      final note = await localNotes.getNote(entry.entityId);
      await remoteNotes.upsertNote(userId, note);
    } on NotFoundFailure {
      // Deleted locally after this was queued: the cloud copy must go too.
      await remoteNotes.deleteNoteIfExists(userId, entry.entityId);
    }
  }
}
