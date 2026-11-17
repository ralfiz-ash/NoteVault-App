import '../../../../core/usecase/usecase.dart';
import '../entities/sync_entities.dart';
import '../repositories/sync_repository.dart';

/// Uploads the signed-in user's queued changes.
class SyncPendingChanges implements UseCase<Future<SyncReport>, String> {
  const SyncPendingChanges(this._repository);

  final SyncRepository _repository;

  @override
  Future<SyncReport> call(String userId) =>
      _repository.syncPendingChanges(userId);
}

class ObservePendingChanges
    implements UseCase<Stream<PendingChanges>, NoParams> {
  const ObservePendingChanges(this._repository);

  final SyncRepository _repository;

  @override
  Stream<PendingChanges> call(NoParams input) =>
      _repository.watchPendingChanges();
}
