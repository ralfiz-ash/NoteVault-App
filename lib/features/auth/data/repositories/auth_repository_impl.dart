import '../../../../core/errors/exception_mapper.dart';
import '../../../../core/errors/guard.dart';
import '../../../../core/logging/app_logger.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required this.remote,
    required this.exceptionMapper,
    this.logger = const NoOpLogger(),
  });

  final AuthRemoteDataSource remote;
  final ExceptionMapper exceptionMapper;
  final AppLogger logger;

  Future<T> _guard<T>(Future<T> Function() action) =>
      guardFailures(action, mapper: exceptionMapper, logger: logger);

  @override
  AppUser? get currentUser => remote.currentUser?.toEntity();

  @override
  Stream<AppUser?> authStateChanges() => guardFailureStream(
    remote.authStateChanges().map((user) => user?.toEntity()),
    mapper: exceptionMapper,
    logger: logger,
  );

  @override
  Future<AppUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) => _guard(() async {
    final user = await remote.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return user.toEntity();
  });

  @override
  Future<AppUser> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) => _guard(() async {
    final user = await remote.registerWithEmailAndPassword(
      email: email,
      password: password,
    );
    return user.toEntity();
  });

  @override
  Future<AppUser> signInWithGoogle() =>
      _guard(() async => (await remote.signInWithGoogle()).toEntity());

  @override
  Future<void> sendPasswordResetEmail(String email) =>
      _guard(() => remote.sendPasswordResetEmail(email));

  @override
  Future<void> signOut() => _guard(remote.signOut);

  @override
  Future<void> reauthenticateWithPassword(String password) =>
      _guard(() => remote.reauthenticateWithPassword(password));

  @override
  Future<void> reauthenticateWithGoogle() =>
      _guard(remote.reauthenticateWithGoogle);

  @override
  Future<void> deleteCurrentUser() => _guard(remote.deleteCurrentUser);
}
