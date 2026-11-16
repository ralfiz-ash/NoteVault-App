import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notevalult/app/app.dart';
import 'package:notevalult/core/errors/failure.dart';
import 'package:notevalult/features/auth/domain/entities/app_user.dart';

import '../../../helpers/fake_repositories.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  late FakeAuthRepository auth;

  Future<void> pumpSignedOut(WidgetTester tester) async {
    auth = FakeAuthRepository()..emit(null);
    await tester.pumpWidget(
      ProviderScope(
        overrides: appTestOverrides(auth: auth),
        child: const NoteVaultApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder email() => find.widgetWithText(TextFormField, 'Email');
  Finder field(String key) => find.byKey(Key(key));

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.ensureVisible(find.text(text));
    await tester.tap(find.text(text));
    await tester.pump();
  }

  group('session restore', () {
    testWidgets('splash while unknown, then straight into the app', (
      tester,
    ) async {
      auth = FakeAuthRepository(); // Firebase has not reported yet
      await tester.pumpWidget(
        ProviderScope(
          overrides: appTestOverrides(auth: auth),
          child: const NoteVaultApp(),
        ),
      );
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Welcome back'), findsNothing);

      auth.emit(testUser); // restored session
      await tester.pumpAndSettle();
      expect(find.text('No notes yet'), findsOneWidget);
    });
  });

  group('login', () {
    testWidgets('validates before calling the repository', (tester) async {
      await pumpSignedOut(tester);
      expect(find.text('Welcome back'), findsOneWidget);

      await tapText(tester, 'Sign in');

      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
      expect(auth.calls, isEmpty);

      await tester.enterText(email(), 'not-an-email');
      await tapText(tester, 'Sign in');
      expect(find.text('Enter a valid email address'), findsOneWidget);
    });

    testWidgets('loading disables actions, success opens the app', (
      tester,
    ) async {
      await pumpSignedOut(tester);
      final gate = auth.gate = Completer<void>();

      await tester.enterText(email(), 'me@example.com');
      await tester.enterText(field('login-password'), 'secret');
      await tapText(tester, 'Sign in');

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      final google = tester.widget<OutlinedButton>(
        find.ancestor(
          of: find.text('Continue with Google'),
          matching: find.byType(OutlinedButton),
        ),
      );
      expect(google.onPressed, isNull);

      gate.complete();
      await tester.pumpAndSettle();

      expect(auth.calls, ['signIn:me@example.com']);
      expect(find.text('No notes yet'), findsOneWidget);
    });

    testWidgets('shows the mapped error once', (tester) async {
      await pumpSignedOut(tester);
      auth.nextError = const AuthFailure(
        message: 'Incorrect email or password.',
      );

      await tester.enterText(email(), 'me@example.com');
      await tester.enterText(field('login-password'), 'wrong');
      await tapText(tester, 'Sign in');
      await tester.pump();

      expect(find.text('Incorrect email or password.'), findsOneWidget);
      expect(find.text('Welcome back'), findsOneWidget);
    });

    testWidgets('Google success opens the app; cancel shows nothing', (
      tester,
    ) async {
      await pumpSignedOut(tester);

      auth.nextError = const CancelledFailure();
      await tapText(tester, 'Continue with Google');
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsNothing);
      expect(find.text('Welcome back'), findsOneWidget);

      auth.nextUser = const AppUser(uid: 'g', email: 'g@example.com');
      await tapText(tester, 'Continue with Google');
      await tester.pumpAndSettle();
      expect(find.text('No notes yet'), findsOneWidget);
      expect(auth.currentUser?.email, 'g@example.com');
    });

    testWidgets('Google failure shows its message', (tester) async {
      await pumpSignedOut(tester);
      auth.nextError = const AuthFailure(
        message: 'Google sign-in failed. Please try again.',
      );

      await tapText(tester, 'Continue with Google');
      await tester.pump();

      expect(
        find.text('Google sign-in failed. Please try again.'),
        findsOneWidget,
      );
    });
  });

  group('register', () {
    Future<void> openRegister(WidgetTester tester) async {
      await pumpSignedOut(tester);
      await tapText(tester, 'Create one');
      await tester.pumpAndSettle();
      expect(find.text('Create your account'), findsOneWidget);
    }

    testWidgets('validates email, length and confirmation', (tester) async {
      await openRegister(tester);

      await tapText(tester, 'Create account');
      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
      expect(find.text('Please confirm your password'), findsOneWidget);

      await tester.enterText(email(), 'new@example.com');
      await tester.enterText(field('register-password'), 'short');
      await tester.enterText(field('register-confirm'), 'different');
      await tapText(tester, 'Create account');
      expect(
        find.text('Password must be at least 8 characters'),
        findsOneWidget,
      );
      expect(find.text('Passwords do not match'), findsOneWidget);
      expect(auth.calls, isEmpty);
    });

    testWidgets('loading then error', (tester) async {
      await openRegister(tester);
      final gate = auth.gate = Completer<void>();
      auth.nextError = const AuthFailure(
        message: 'An account already exists for this email.',
      );

      await tester.enterText(email(), 'new@example.com');
      await tester.enterText(field('register-password'), 'longenough');
      await tester.enterText(field('register-confirm'), 'longenough');
      await tapText(tester, 'Create account');
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      gate.complete();
      await tester.pump();
      await tester.pump();

      expect(
        find.text('An account already exists for this email.'),
        findsOneWidget,
      );
      // Only the visible screen reports it (login is below in the stack).
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('success opens the app', (tester) async {
      await openRegister(tester);
      await tester.enterText(email(), 'new@example.com');
      await tester.enterText(field('register-password'), 'longenough');
      await tester.enterText(field('register-confirm'), 'longenough');
      await tapText(tester, 'Create account');
      await tester.pumpAndSettle();

      expect(auth.calls, ['register:new@example.com']);
      expect(find.text('No notes yet'), findsOneWidget);
    });
  });

  group('forgot password', () {
    Future<void> openForgot(WidgetTester tester) async {
      await pumpSignedOut(tester);
      await tapText(tester, 'Forgot password?');
      await tester.pumpAndSettle();
      expect(find.text('Reset your password'), findsOneWidget);
    }

    testWidgets('validates the email', (tester) async {
      await openForgot(tester);
      await tapText(tester, 'Send reset link');
      expect(find.text('Email is required'), findsOneWidget);
      expect(auth.calls, isEmpty);
    });

    testWidgets('loading then a neutral success message', (tester) async {
      await openForgot(tester);
      final gate = auth.gate = Completer<void>();

      await tester.enterText(email(), 'me@example.com');
      await tapText(tester, 'Send reset link');
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      gate.complete();
      await tester.pumpAndSettle();

      expect(auth.calls, ['reset:me@example.com']);
      expect(
        find.textContaining('If an account exists for me@example.com'),
        findsOneWidget,
      );

      await tapText(tester, 'Back to sign in');
      await tester.pumpAndSettle();
      expect(find.text('Welcome back'), findsOneWidget);
    });

    testWidgets('shows errors', (tester) async {
      await openForgot(tester);
      auth.nextError = const NetworkFailure();

      await tester.enterText(email(), 'me@example.com');
      await tapText(tester, 'Send reset link');
      await tester.pump();

      expect(find.text(const NetworkFailure().message), findsOneWidget);
    });
  });

  testWidgets('logout returns to login', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: appTestOverrides(
          auth: auth = FakeAuthRepository.signedIn(testUser),
        ),
        child: const NoteVaultApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('No notes yet'), findsOneWidget);

    await tester.tap(find.byTooltip('Sign out'));
    await tester.pumpAndSettle();

    expect(auth.calls, ['signOut']);
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('No notes yet'), findsNothing);
  });
}
