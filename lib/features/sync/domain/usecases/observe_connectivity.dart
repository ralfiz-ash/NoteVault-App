import '../../../../core/usecase/usecase.dart';
import '../entities/connectivity_status.dart';
import '../repositories/connectivity_repository.dart';

class ObserveConnectivity
    implements UseCase<Stream<ConnectivityStatus>, NoParams> {
  const ObserveConnectivity(this._repository);

  final ConnectivityRepository _repository;

  @override
  Stream<ConnectivityStatus> call(NoParams input) => _repository.watchStatus();
}
