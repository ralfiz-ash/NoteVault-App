import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notevalult/app/app.dart';
import 'package:notevalult/app/provider_retry.dart';
import 'package:notevalult/app/router/app_router.dart';
import 'package:notevalult/app/router/app_routes.dart';
import 'package:notevalult/core/errors/failure.dart';
import 'package:notevalult/features/auth/domain/entities/app_user.dart';
import 'package:notevalult/features/auth/domain/entities/sign_in_method.dart';
import 'package:notevalult/features/sync/domain/entities/connectivity_status.dart';

import '../../../helpers/fake_repositories.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  late FakeAuthRepository auth;
  late FakeUserDataRepository userData;
  late FakeConnectivityRepository connectivity;

  const googleUser = AppUser(
    uid: 'g-user',
    email: 'g@example.com',
    signInMethods: {SignInMethod.google},
  );

  Future<void> openDeleteScreen(
    WidgetTester tester, {
    AppUser user = testUser,
  }) async {
    auth = FakeAuthRepository.signedIn(user);
    userData = FakeUserDataRepository(log: auth.calls);
    connectivity = FakeConnectivityRepository();
    final container = ProviderContainer(
      retry: providerRetry,
      overrides: appTestOverrides(
        auth: auth,
        userData: userData,
        connectivity: connectivity,
      ),
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const NoteVaultApp(),
      ),
    );
    await tester.pumpAndSettle();
    container.read(appRouterProvider).go(AppRoutes.deleteAccount);
    await tester.pumpAndSettle();
  }

  Finder deleteButton() => find.byKey(const Key('delete-account-button'));

  Future<void> tapDeleteAndConfirm(WidgetTester tester) async {
    await tester.ensureVisible(deleteButton());
    await tester.tap(deleteButton());
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pumpAndSettle();
  }

  testWidgets('Settings has a Delete account entry that opens the screen', (
    tester,
  ) async {
    await openDeleteScreen(tester);
    // Back to Settings, then use the entry.
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    final container = ProviderScope.containerOf(
      tester.element(find.byType(NoteVaultApp)),
    );
    container.read(appRouterProvider).go(AppRoutes.settings);
    await tester.pumpAndSettle();

    final tile = find.byKey(const Key('delete-account-tile'));
    await tester.scrollUntilVisible(
      tile,
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(tile);
    await tester.pumpAndSettle();
    expect(find.text('Delete your NoteVault account?'), findsOneWidget);
  });

  testWidgets('password account: confirm, delete everything, signed out', (
    tester,
  ) async {
    await openDeleteScreen(tester);
    await tester.enterText(
      find.byKey(const Key('delete-account-password')),
      'secret',
    );
    await tapDeleteAndConfirm(tester);

    expect(auth.calls, [
      'reauth:password',
      'discardPendingSync',
      'deleteCloud:test-user',
      'deleteLocal',
      'deleteUser',
    ]);
    expect(find.text('Welcome back'), findsOneWidget); // login screen
    expect(find.text('Your account and notes were deleted.'), findsOneWidget);
  });

  testWidgets('the password is required', (tester) async {
    await openDeleteScreen(tester);
    await tester.ensureVisible(deleteButton());
    await tester.tap(deleteButton());
    await tester.pumpAndSettle();

    expect(find.text('Enter your password to confirm.'), findsWidgets);
    expect(find.text('Delete account permanently?'), findsNothing);
    expect(auth.calls, isEmpty);
  });

  testWidgets('cancelling the confirmation deletes nothing', (tester) async {
    await openDeleteScreen(tester);
    await tester.enterText(
      find.byKey(const Key('delete-account-password')),
      'secret',
    );
    await tester.ensureVisible(deleteButton());
    await tester.tap(deleteButton());
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Cancel').last);
    await tester.pumpAndSettle();

    expect(auth.calls, isEmpty);
  });

  testWidgets('wrong password: error shown, still signed in', (tester) async {
    await openDeleteScreen(tester);
    auth.nextError = const AuthFailure(message: 'Incorrect password.');
    await tester.enterText(
      find.byKey(const Key('delete-account-password')),
      'wrong',
    );
    await tapDeleteAndConfirm(tester);

    expect(
      find.text('Unable to delete account. Incorrect password.'),
      findsOneWidget,
    );
    expect(find.text('Delete your NoteVault account?'), findsOneWidget);
    expect(auth.calls, ['reauth:password']);
  });

  testWidgets('cloud deletion fails: error shown, account kept', (
    tester,
  ) async {
    await openDeleteScreen(tester);
    userData.failOn['deleteCloud:test-user'] = const NetworkFailure();
    await tester.enterText(
      find.byKey(const Key('delete-account-password')),
      'secret',
    );
    await tapDeleteAndConfirm(tester);

    expect(find.textContaining('Unable to delete account'), findsOneWidget);
    expect(auth.calls, isNot(contains('deleteUser')));
    expect(auth.currentUser, isNotNull);
  });

  testWidgets('Google account: confirms with Google; cancel is silent', (
    tester,
  ) async {
    await openDeleteScreen(tester, user: googleUser);
    expect(find.byKey(const Key('delete-account-password')), findsNothing);
    expect(find.text('Confirm with Google and delete'), findsOneWidget);

    auth.nextError = const CancelledFailure();
    await tapDeleteAndConfirm(tester);
    expect(auth.calls, ['reauth:google']);
    expect(find.textContaining('Unable to delete account'), findsNothing);

    await tapDeleteAndConfirm(tester);
    expect(auth.calls.last, 'deleteUser');
    expect(find.text('Welcome back'), findsOneWidget);
  });

  testWidgets('offline: explains why and disables deleting', (tester) async {
    await openDeleteScreen(tester);
    connectivity.emit(ConnectivityStatus.disconnected);
    await tester.pumpAndSettle();

    expect(find.textContaining("You're offline"), findsOneWidget);
    expect(tester.widget<FilledButton>(deleteButton()).onPressed, isNull);
  });
}
