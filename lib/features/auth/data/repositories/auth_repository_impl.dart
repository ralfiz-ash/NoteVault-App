import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this.remote);

  final AuthRemoteDataSource remote;

  @override
  Stream<AppUser?> authStateChanges() =>
      throw UnimplementedError('Implemented in the Authentication phase.');

  @override
  Future<void> signOut() =>
      throw UnimplementedError('Implemented in the Authentication phase.');
}
