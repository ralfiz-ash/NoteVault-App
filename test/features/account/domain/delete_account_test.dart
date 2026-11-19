import 'package:flutter_test/flutter_test.dart';
import 'package:notevalult/core/errors/failure.dart';
import 'package:notevalult/features/account/domain/entities/account_deletion_confirmation.dart';
import 'package:notevalult/features/account/domain/usecases/delete_account.dart';
import 'package:notevalult/features/auth/domain/entities/app_user.dart';

import '../../../helpers/fake_repositories.dart';

void main() {
  late FakeAuthRepository auth;
  late FakeUserDataRepository userData;
  late DeleteAccount deleteAccount;

  setUp(() {
    auth = FakeAuthRepository.signedIn(const AppUser(uid: 'u1'));
    userData = FakeUserDataRepository(log: auth.calls); // one shared log
    deleteAccount = DeleteAccount(auth: auth, userData: userData);
  });

  test(
    'password: confirms, stops sync, deletes cloud, local, then account',
    () async {
      await deleteAccount(const ConfirmWithPassword('secret'));

      expect(auth.calls, [
        'reauth:password',
        'discardPendingSync',
        'deleteCloud:u1',
        'deleteLocal',
        'deleteUser',
      ]);
      expect(auth.currentUser, isNull); // signed out
    },
  );

  test('Google: confirms with Google first', () async {
    await deleteAccount(const ConfirmWithGoogle());
    expect(auth.calls.first, 'reauth:google');
    expect(auth.calls.last, 'deleteUser');
  });

  test('empty password fails validation; nothing is touched', () async {
    await expectLater(
      deleteAccount(const ConfirmWithPassword('')),
      throwsA(isA<ValidationFailure>()),
    );
    expect(auth.calls, isEmpty);
  });

  test('wrong password or cancelled Google: nothing is deleted', () async {
    auth.nextError = const AuthFailure(message: 'Incorrect password.');
    await expectLater(
      deleteAccount(const ConfirmWithPassword('wrong')),
      throwsA(isA<AuthFailure>()),
    );
    auth.nextError = const CancelledFailure();
    await expectLater(
      deleteAccount(const ConfirmWithGoogle()),
      throwsA(isA<CancelledFailure>()),
    );
    expect(auth.calls, ['reauth:password', 'reauth:google']);
    expect(auth.currentUser, isNotNull);
  });

  test(
    'cloud deletion fails (offline): local data and account are kept',
    () async {
      userData.failOn['deleteCloud:u1'] = const NetworkFailure();

      await expectLater(
        deleteAccount(const ConfirmWithPassword('secret')),
        throwsA(isA<NetworkFailure>()),
      );
      expect(auth.calls, isNot(contains('deleteLocal')));
      expect(auth.calls, isNot(contains('deleteUser')));
      expect(auth.currentUser, isNotNull); // can simply try again
    },
  );

  test('signed out: fails without doing anything', () async {
    auth.emit(null);
    await expectLater(
      deleteAccount(const ConfirmWithGoogle()),
      throwsA(isA<AuthFailure>()),
    );
    expect(auth.calls, isEmpty);
  });

  test('the password never appears in the confirmation text', () {
    expect(
      const ConfirmWithPassword('topsecret').toString(),
      isNot(contains('topsecret')),
    );
  });
}
