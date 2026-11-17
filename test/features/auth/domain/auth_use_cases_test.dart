import 'package:flutter_test/flutter_test.dart';
import 'package:notevalult/core/errors/failure.dart';
import 'package:notevalult/core/usecase/usecase.dart';
import 'package:notevalult/features/auth/domain/entities/app_user.dart';
import 'package:notevalult/features/auth/domain/usecases/email_password_params.dart';
import 'package:notevalult/features/auth/domain/usecases/observe_auth_state.dart';
import 'package:notevalult/features/auth/domain/usecases/register_with_email.dart';
import 'package:notevalult/features/auth/domain/usecases/send_password_reset.dart';
import 'package:notevalult/features/auth/domain/usecases/sign_in_with_email.dart';
import 'package:notevalult/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:notevalult/features/auth/domain/usecases/sign_out.dart';

import '../../../helpers/fake_repositories.dart';

void main() {
  late FakeAuthRepository repo;
  setUp(() => repo = FakeAuthRepository());

  const goodLogin = EmailPasswordParams(email: ' a@b.co ', password: 'secret');

  group('SignInWithEmail (login)', () {
    test('success returns the user and trims the email', () async {
      final user = await SignInWithEmail(repo)(goodLogin);
      expect(user.uid, 'u1');
      expect(repo.calls, ['signIn:a@b.co']);
    });

    test('repository failure propagates', () async {
      repo.nextError = const AuthFailure(
        message: 'Incorrect email or password.',
      );
      await expectLater(
        SignInWithEmail(repo)(goodLogin),
        throwsA(isA<AuthFailure>()),
      );
    });

    test('invalid input never reaches the repository', () async {
      await expectLater(
        SignInWithEmail(repo)(
          const EmailPasswordParams(email: 'bad', password: ''),
        ),
        throwsA(
          isA<ValidationFailure>().having(
            (f) => f.fieldErrors.keys,
            'fields',
            containsAll(['email', 'password']),
          ),
        ),
      );
      expect(repo.calls, isEmpty);
    });
  });

  group('RegisterWithEmail', () {
    test('success', () async {
      final user = await RegisterWithEmail(repo)(
        const EmailPasswordParams(email: 'n@b.co', password: 'longenough'),
      );
      expect(user.uid, 'u1');
      expect(repo.calls, ['register:n@b.co']);
    });

    test('repository failure propagates', () async {
      repo.nextError = const AuthFailure(
        message: 'An account already exists for this email.',
      );
      await expectLater(
        RegisterWithEmail(repo)(
          const EmailPasswordParams(email: 'n@b.co', password: 'longenough'),
        ),
        throwsA(isA<AuthFailure>()),
      );
    });

    test('a short password is rejected before the repository', () async {
      await expectLater(
        RegisterWithEmail(repo)(
          const EmailPasswordParams(email: 'n@b.co', password: 'short'),
        ),
        throwsA(isA<ValidationFailure>()),
      );
      expect(repo.calls, isEmpty);
    });
  });

  group('SignInWithGoogle', () {
    test('success', () async {
      expect((await SignInWithGoogle(repo)(const NoParams())).uid, 'u1');
    });

    test('cancellation surfaces as CancelledFailure', () async {
      repo.nextError = const CancelledFailure();
      await expectLater(
        SignInWithGoogle(repo)(const NoParams()),
        throwsA(isA<CancelledFailure>()),
      );
    });
  });

  group('SendPasswordReset (forgot password)', () {
    test('success sends to the trimmed email', () async {
      await SendPasswordReset(repo)(' r@b.co ');
      expect(repo.calls, ['reset:r@b.co']);
    });

    test('repository failure propagates', () async {
      repo.nextError = const NetworkFailure();
      await expectLater(
        SendPasswordReset(repo)('r@b.co'),
        throwsA(isA<NetworkFailure>()),
      );
    });

    test('invalid email is rejected first', () async {
      await expectLater(
        SendPasswordReset(repo)('nope'),
        throwsA(isA<ValidationFailure>()),
      );
      expect(repo.calls, isEmpty);
    });
  });

  group('SignOut (logout)', () {
    test('success', () async {
      await SignOut(repo)(const NoParams());
      expect(repo.calls, ['signOut']);
    });

    test('repository failure propagates', () async {
      repo.nextError = const NetworkFailure();
      await expectLater(
        SignOut(repo)(const NoParams()),
        throwsA(isA<NetworkFailure>()),
      );
    });
  });

  group('ObserveAuthState', () {
    test('emits authenticated and unauthenticated states', () async {
      final states = <AppUser?>[];
      final sub = ObserveAuthState(repo)(const NoParams()).listen(states.add);
      addTearDown(sub.cancel);
      await pumpEventQueue();

      repo.emit(const AppUser(uid: 'u1'));
      repo.emit(null);
      await pumpEventQueue();

      expect(states.map((u) => u?.uid), ['u1', null]);
    });
  });

  test('params never print the password', () {
    expect(goodLogin.toString(), isNot(contains('secret')));
  });
}
