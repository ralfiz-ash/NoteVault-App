import '../../../../core/database/local_transaction.dart';
import '../../../../core/database/sync_queue_store.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/utils/clock.dart';
import '../../../../core/utils/id_generator.dart';
import '../../../folders/domain/entities/folder.dart';
import '../../../folders/domain/repositories/folder_repository.dart';
import '../../../notes/domain/entities/note.dart';
import '../../../notes/domain/entities/note_versioning.dart';
import '../../../notes/domain/entities/remote_note_change.dart';
import '../../../notes/domain/repositories/note_remote_repository.dart';
import '../../../notes/domain/repositories/note_repository.dart';
import '../../domain/entities/sync_entities.dart';
import '../../domain/repositories/sync_repository.dart';

/// Both sync directions for notes.
///
/// Upload (queue -> cloud): claim each queued note, send the CURRENT local
/// note only if the cloud does not already hold a newer revision (atomic
/// check), then remove it from the queue. A newer cloud revision is a
/// conflict: the cloud version is applied locally and the losing local text
/// is kept as a conflict copy.
///
/// Download (cloud -> local): cloud changes are written with
/// `applyRemoteNote` / `applyRemoteDelete`, which never record an outgoing
/// change, so nothing bounces back to the cloud. Echoes of this device's
/// own uploads compare equal and are ignored.
class SyncRepositoryImpl implements SyncRepository {
  SyncRepositoryImpl({
    required this.queue,
    required this.localNotes,
    required this.remoteNotes,
    required this.folders,
    required this.transactions,
    required this.idGenerator,
    required this.clock,
    this.logger = const NoOpLogger(),
  });

  final SyncQueueStore queue;
  final NoteRepository localNotes;
  final NoteRemoteRepository remoteNotes;
  final FolderRepository folders;
  final LocalTransactionRunner transactions;
  final IdGenerator idGenerator;
  final Clock clock;
  final AppLogger logger;

  Future<SyncReport>? _running;
  bool _runAgain = false;

  // ---- Upload ---------------------------------------------------------------

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
      if (pass.error is NetworkFailure || pass.error is AuthFailure) break;
    } while (_runAgain);
    return report;
  }

  Future<SyncReport> _runOnce(String userId) async {
    var synced = 0;
    var failed = 0;
    var conflicts = 0;
    Failure? firstError;
    try {
      await queue.releaseInterrupted();
      for (final entry in await queue.due()) {
        if (entry.entityType != SyncEntity.note) continue;
        if (!await queue.claim(entry)) continue; // changed or taken
        try {
          if (await _push(userId, entry)) conflicts++;
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
      logger.error('Sync run failed', error: error, stackTrace: stackTrace);
      firstError ??= error is Failure
          ? error
          : UnknownFailure(cause: error, stackTrace: stackTrace);
    }
    return SyncReport(
      synced: synced,
      failed: failed,
      conflicts: conflicts,
      error: firstError,
    );
  }

  /// Uploads one queued change. Returns `true` if it met a conflict.
  Future<bool> _push(String userId, SyncQueueEntry entry) async {
    final id = entry.entityId;
    Note? local;
    if (entry.operation != SyncOperation.delete) {
      try {
        local = await localNotes.getNote(id);
      } on NotFoundFailure {
        local = null; // deleted after it was queued
      }
    }

    if (local == null) {
      final newerInCloud = await remoteNotes.deleteUnlessEdited(
        userId,
        id,
        entry.entityVersion ?? 0x7fffffff,
      );
      if (newerInCloud == null) return false;
      // Edited on another device after we deleted it: the edit wins.
      await transactions.run(() async {
        await _ensureFolder(newerInCloud, null);
        await localNotes.applyRemoteNote(newerInCloud);
        await queue.remove(SyncEntity.note, id);
      });
      return true;
    }

    final newerInCloud = await remoteNotes.upsertUnlessNewer(
      userId,
      local,
      folderName: await _folderName(local.folderId),
    );
    if (newerInCloud == null) return false;
    await transactions.run(() async {
      await _resolveLocalLoss(local!, newerInCloud);
      await queue.remove(SyncEntity.note, id);
    });
    return true;
  }

  // ---- Download -------------------------------------------------------------

  @override
  Stream<RemoteSyncReport> followRemoteChanges(String userId) => remoteNotes
      .watchChanges(userId)
      .asyncMap((changes) => transactions.run(() => _applyAll(changes)));

  Future<RemoteSyncReport> _applyAll(List<RemoteNoteChange> changes) async {
    var applied = 0;
    var conflicts = 0;
    for (final change in changes) {
      final (didApply, didConflict) = await _apply(change);
      if (didApply) applied++;
      if (didConflict) conflicts++;
    }
    return RemoteSyncReport(applied: applied, conflicts: conflicts);
  }

  /// Applies one cloud change. Returns (applied locally, was a conflict).
  Future<(bool, bool)> _apply(RemoteNoteChange change) async {
    final id = change.noteId;
    final pending = await queue.entry(SyncEntity.note, id);
    final local = await _localOrNull(id);

    if (change.type == RemoteChangeType.removed) {
      if (pending == null) {
        if (local == null) return (false, false);
        await localNotes.applyRemoteDelete(id);
        return (true, false);
      }
      if (pending.operation == SyncOperation.delete) {
        await queue.remove(SyncEntity.note, id); // deleted on both sides
        return (false, false);
      }
      // Unsynced local edit vs cloud delete: the edit wins and its pending
      // upload re-creates the note.
      return (false, true);
    }

    final cloud = change.note!;
    if (pending == null ||
        local == null && pending.operation != SyncOperation.delete) {
      if (local != null && !NoteVersioning.isNewer(cloud, local)) {
        return (false, false); // already have it (e.g. echo of our upload)
      }
      await _ensureFolder(cloud, change.folderName);
      await localNotes.applyRemoteNote(cloud);
      if (pending != null) await queue.remove(SyncEntity.note, id);
      return (true, false);
    }

    if (pending.operation == SyncOperation.delete) {
      if (cloud.version <= (pending.entityVersion ?? 0)) {
        return (false, false); // our delete is newer; it will upload
      }
      // Edited elsewhere after we deleted it: the edit wins.
      await _ensureFolder(cloud, change.folderName);
      await localNotes.applyRemoteNote(cloud);
      await queue.remove(SyncEntity.note, id);
      return (true, true);
    }

    // Local unsynced edit (local != null here).
    if (NoteVersioning.sameContent(cloud, local!)) {
      if (cloud.version >= local.version) {
        await localNotes.applyRemoteNote(cloud);
        await queue.remove(SyncEntity.note, id);
      }
      return (false, false);
    }
    if (NoteVersioning.isNewer(cloud, local)) {
      await _ensureFolder(cloud, change.folderName);
      await _resolveLocalLoss(local, cloud);
      await queue.remove(SyncEntity.note, id);
      return (true, true);
    }
    return (false, false); // ours is newer; the pending upload wins
  }

  // ---- Helpers --------------------------------------------------------------

  /// The cloud note wins: apply it, and keep the losing local text as a new
  /// "conflict copy" note (a normal local change, uploaded later).
  Future<void> _resolveLocalLoss(Note local, Note cloud) async {
    await _ensureFolder(cloud, null);
    await localNotes.applyRemoteNote(cloud);
    if (NoteVersioning.sameContent(local, cloud)) return;
    final now = clock().toUtc();
    await localNotes.createNote(
      Note(
        id: idGenerator.newId(),
        title: '${local.title} (conflict copy)',
        content: local.content,
        folderId: local.folderId,
        tags: local.tags,
        createdAt: now,
        updatedAt: now,
      ),
    );
    logger.info('Sync conflict: local edit kept as a copy');
  }

  /// Makes sure the note's folder exists locally (folders travel inside the
  /// note documents as id + name).
  Future<void> _ensureFolder(Note note, String? folderName) async {
    final folderId = note.folderId;
    if (folderId == null) return;
    if (folderName != null) {
      return folders.applyRemoteFolder(
        Folder(id: folderId, name: folderName, createdAt: note.createdAt),
      );
    }
    try {
      await folders.getFolder(folderId);
    } on NotFoundFailure {
      await folders.applyRemoteFolder(
        Folder(id: folderId, name: 'Folder', createdAt: note.createdAt),
      );
    }
  }

  Future<String?> _folderName(String? folderId) async {
    if (folderId == null) return null;
    try {
      return (await folders.getFolder(folderId)).name;
    } on NotFoundFailure {
      return null;
    }
  }

  Future<Note?> _localOrNull(String id) async {
    try {
      return await localNotes.getNote(id);
    } on NotFoundFailure {
      return null;
    }
  }
}
