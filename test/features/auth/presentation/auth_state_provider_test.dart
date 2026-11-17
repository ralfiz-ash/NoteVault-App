import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notevalult/app/di/firebase_providers.dart';
import 'package:notevalult/core/errors/failure.dart';
import 'package:notevalult/features/auth/domain/entities/app_user.dart';
import 'package:notevalult/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:notevalult/features/auth/presentation/state/auth_state.dart';

import '../../../helpers/fake_repositories.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  late FakeAuthRepository auth;
  late ProviderContainer container;
  late List<AsyncValue<AuthState>> states;

  setUp(() {
    auth = FakeAuthRepository();
    container = createContainer(
      overrides: [authRepositoryProvider.overrideWithValue(auth)],
    );
    states = [];
    container.listen(
      authStateProvider,
      (_, next) => states.add(next),
      fireImmediately: true,
    );
  });

  test('starts loading, then follows sign-in and sign-out', () async {
    expect(states.single, isA<AsyncLoading<AuthState>>());

    auth.emit(null);
    await pumpEventQueue();
    expect(states.last.value, const Unauthenticated());

    const user = AppUser(uid: 'u1', email: 'a@b.c');
    auth.emit(user);
    await pumpEventQueue();
    expect(states.last.value, const Authenticated(user));

    auth.emit(null);
    await pumpEventQueue();
    expect(states.last.value, const Unauthenticated());
  });

  test('auth stream failures surface as AsyncError(Failure)', () async {
    auth.emitError(const NetworkFailure());
    await pumpEventQueue();

    expect(states.last.hasError, isTrue);
    expect(states.last.error, isA<NetworkFailure>());
  });

  test('exposes app-level state, not SDK types', () async {
    auth.emit(const AppUser(uid: 'u2'));
    await pumpEventQueue();

    final state = container.read(authStateProvider).value;
    expect(state, isA<Authenticated>());
    expect((state! as Authenticated).user.uid, 'u2');
  });
}
