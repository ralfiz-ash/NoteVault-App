import '../../../../core/errors/exception_mapper.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/guard.dart';
import '../../../../core/logging/app_logger.dart';
import '../../domain/entities/tag.dart';
import '../../domain/repositories/tag_repository.dart';
import '../datasources/tag_local_data_source.dart';

class TagRepositoryImpl implements TagRepository {
  const TagRepositoryImpl({
    required this.local,
    required this.exceptionMapper,
    this.logger = const NoOpLogger(),
  });

  final TagLocalDataSource local;
  final ExceptionMapper exceptionMapper;
  final AppLogger logger;

  @override
  Stream<List<Tag>> watchTags() => guardFailureStream(
    local.watchTags().map((m) => [for (final t in m) t.toEntity()]),
    mapper: exceptionMapper,
    logger: logger,
  );

  @override
  Future<List<Tag>> getTags() => guardFailures(
    () async {
      final models = await local.getTags();
      return [for (final m in models) m.toEntity()];
    },
    mapper: exceptionMapper,
    logger: logger,
  );

  @override
  Future<void> deleteTag(String id) => guardFailures(
    () async {
      if (!await local.deleteTag(id)) {
        throw NotFoundFailure(message: 'Tag not found.', cause: id);
      }
    },
    mapper: exceptionMapper,
    logger: logger,
  );
}
