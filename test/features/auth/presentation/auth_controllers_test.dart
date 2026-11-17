import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notevalult/app/di/firebase_providers.dart';
import 'package:notevalult/core/errors/failure.dart';
import 'package:notevalult/features/auth/presentation/providers/auth_controller.dart';
import 'package:notevalult/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:notevalult/features/auth/presentation/providers/password_reset_controller.dart';
import 'package:notevalult/features/auth/presentation/state/auth_state.dart';

import '../../../helpers/fake_repositories.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  late FakeAuthRepository repo;
  late ProviderContainer container;

  setUp(() {
    repo = FakeAuthRepository()..emit(null);
    container = createContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repo)],
    );
    container.listen(authControllerProvider, (_, _) {});
    container.listen(authStateProvider, (_, _) {});
  });

  AuthController controller() =>
      container.read(authControllerProvider.notifier);

  test(
    'sign-in: loading, then success; auth state becomes Authenticated',
    () async {
      final gate = repo.gate = Completer<void>();
      final future = controller().signIn(email: 'a@b.co', password: 'pw');
      expect(container.read(authControllerProvider).isLoading, isTrue);

      gate.complete();
      expect(await future, isTrue);
      await pumpEventQueue();

      expect(container.read(authControllerProvider).hasError, isFalse);
      expect(container.read(authStateProvider).value, isA<Authenticated>());
    },
  );

  test('a second request while loading is ignored', () async {
    final gate = Completer<void>();
    repo.gate = gate;
    final first = controller().signIn(email: 'a@b.co', password: 'pw');
    expect(await controller().signInWithGoogle(), isFalse);

    gate.complete();
    await first;
    expect(repo.calls, ['signIn:a@b.co']);
  });

  test('failures become AsyncError(Failure)', () async {
    repo.nextError = const AuthFailure(message: 'Incorrect email or password.');

    expect(await controller().signIn(email: 'a@b.co', password: 'pw'), isFalse);

    final error = container.read(authControllerProvider).error;
    expect(error, isA<AuthFailure>());
    expect((error! as Failure).message, 'Incorrect email or password.');
  });

  test('state never contains the password', () async {
    await controller().signIn(email: 'a@b.co', password: 'topsecret');
    expect(
      container.read(authControllerProvider).toString(),
      isNot(contains('topsecret')),
    );
  });

  test('sign-out makes the session Unauthenticated', () async {
    await controller().signInWithGoogle();
    await pumpEventQueue();
    await controller().signOut();
    await pumpEventQueue();

    expect(container.read(authStateProvider).value, const Unauthenticated());
  });

  group('password reset', () {
    test('idle -> loading -> sent', () async {
      container.listen(passwordResetControllerProvider, (_, _) {});
      expect(container.read(passwordResetControllerProvider).value, isFalse);

      final gate = repo.gate = Completer<void>();
      final future = container
          .read(passwordResetControllerProvider.notifier)
          .send('r@b.co');
      expect(container.read(passwordResetControllerProvider).isLoading, isTrue);
      gate.complete();
      await future;

      expect(container.read(passwordResetControllerProvider).value, isTrue);
    });

    test('errors are exposed', () async {
      container.listen(passwordResetControllerProvider, (_, _) {});
      repo.nextError = const NetworkFailure();

      await container
          .read(passwordResetControllerProvider.notifier)
          .send('r@b.co');

      expect(
        container.read(passwordResetControllerProvider).error,
        isA<NetworkFailure>(),
      );
    });
  });
}
