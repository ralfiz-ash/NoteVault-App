import '../../../../core/database/local_transaction.dart';
import '../../../../core/database/sync_queue_store.dart';
import '../../../../core/errors/exception_mapper.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/guard.dart';
import '../../../../core/logging/app_logger.dart';
import '../../domain/entities/tag.dart';
import '../../domain/repositories/tag_repository.dart';
import '../datasources/tag_local_data_source.dart';
import '../models/tag_model.dart';

class TagRepositoryImpl implements TagRepository {
  const TagRepositoryImpl({
    required this.local,
    required this.exceptionMapper,
    this.logger = const NoOpLogger(),
    this.outbox,
    this.transactions = const NoTransactionRunner(),
  });

  final TagLocalDataSource local;
  final ExceptionMapper exceptionMapper;
  final AppLogger logger;

  /// Notes carry tag names, so renaming or deleting a tag changes the notes
  /// that use it; those notes are queued for upload.
  final SyncOutbox? outbox;
  final LocalTransactionRunner transactions;

  Future<void> _queueNotesUsing(String tagId) async {
    final box = outbox;
    if (box == null) return;
    await local.bumpNoteVersions(tagId);
    for (final noteId in await local.noteIdsWithTag(tagId)) {
      await box.record(SyncEntity.note, noteId, SyncOperation.update);
    }
  }

  Future<T> _guard<T>(Future<T> Function() action) =>
      guardFailures(action, mapper: exceptionMapper, logger: logger);

  @override
  Stream<List<Tag>> watchTags() => guardFailureStream(
    local.watchTags().map((m) => [for (final t in m) t.toEntity()]),
    mapper: exceptionMapper,
    logger: logger,
  );

  @override
  Future<List<Tag>> getTags() => _guard(() async {
    final models = await local.getTags();
    return [for (final m in models) m.toEntity()];
  });

  @override
  Future<Tag> createTag(Tag tag) => _guard(() async {
    await _ensureNameFree(tag.name);
    await local.insertTag(TagModel.fromEntity(tag));
    return _require(tag.id);
  });

  @override
  Future<Tag> updateTag(Tag tag) => _guard(() async {
    await _ensureNameFree(tag.name, exceptId: tag.id);
    await transactions.run(() async {
      final before = await local.getTag(tag.id);
      if (!await local.updateTag(TagModel.fromEntity(tag))) {
        throw _notFound(tag.id);
      }
      // A colour change stays local; a rename changes the notes' tag names.
      if (before != null && before.name != tag.name) {
        await _queueNotesUsing(tag.id);
      }
    });
    return _require(tag.id);
  });

  @override
  Future<void> deleteTag(String id) => _guard(() async {
    await transactions.run(() async {
      await _queueNotesUsing(id);
      if (!await local.deleteTag(id)) throw _notFound(id);
    });
  });

  Future<void> _ensureNameFree(String name, {String? exceptId}) async {
    final existing = await local.findByName(name);
    if (existing != null && existing.id != exceptId) {
      throw ValidationFailure(
        message: 'A tag named "${existing.name}" already exists.',
        fieldErrors: const {'name': 'This tag already exists'},
      );
    }
  }

  Future<Tag> _require(String id) async {
    final model = await local.getTag(id);
    if (model == null) throw _notFound(id);
    return model.toEntity();
  }

  NotFoundFailure _notFound(String id) =>
      NotFoundFailure(message: 'Tag not found.', cause: id);
}
