import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notevalult/app/di/database_providers.dart';
import 'package:notevalult/app/di/firebase_providers.dart';
import 'package:notevalult/app/di/repository_providers.dart';
import 'package:notevalult/core/analytics/app_analytics.dart';
import 'package:notevalult/core/errors/failure.dart';
import 'package:notevalult/core/firebase/firebase_app_analytics.dart';
import 'package:notevalult/core/logging/app_logger.dart';
import 'package:notevalult/features/auth/presentation/providers/auth_controller.dart';
import 'package:notevalult/features/notes/domain/entities/note_draft.dart';
import 'package:notevalult/features/notes/presentation/providers/create_note_controller.dart';
import 'package:notevalult/features/notes/presentation/providers/update_note_controller.dart';

import '../../helpers/fake_repositories.dart';
import '../../helpers/fixtures.dart';
import '../../helpers/sequence_id_generator.dart';
import '../../helpers/test_helpers.dart';

void main() {
  late FakeAnalytics analytics;

  setUp(() => analytics = FakeAnalytics());

  group('login', () {
    late FakeAuthRepository auth;
    late ProviderContainer container;

    setUp(() {
      auth = FakeAuthRepository()..emit(null);
      container = createContainer(
        overrides: [authRepositoryProvider.overrideWithValue(auth)],
        analytics: analytics,
      );
      container.listen(authControllerProvider, (_, _) {});
    });

    AuthController controller() =>
        container.read(authControllerProvider.notifier);

    test('successful email sign-in logs one login (method email)', () async {
      expect(
        await controller().signIn(email: 'a@b.co', password: 'secret'),
        isTrue,
      );
      await pumpEventQueue();
      expect(analytics.events, ['login:email']);
    });

    test('successful Google sign-in logs one login (method google)', () async {
      expect(await controller().signInWithGoogle(), isTrue);
      await pumpEventQueue();
      expect(analytics.events, ['login:google']);
    });

    test('failed or cancelled sign-in logs nothing', () async {
      auth.nextError = const AuthFailure(message: 'Incorrect password.');
      await controller().signIn(email: 'a@b.co', password: 'wrong');
      auth.nextError = const CancelledFailure();
      await controller().signInWithGoogle();
      await pumpEventQueue();
      expect(analytics.events, isEmpty);
    });

    test('registration and sign-out are not logged as login', () async {
      await controller().register(email: 'new@b.co', password: 'secret12');
      await controller().signOut();
      await pumpEventQueue();
      expect(analytics.events, isEmpty);
    });
  });

  group('note_saved', () {
    late FakeNoteRepository notes;
    late ProviderContainer container;

    setUp(() {
      notes = FakeNoteRepository(clock: () => DateTime.utc(2026, 12));
      container = createContainer(
        overrides: [
          noteRepositoryProvider.overrideWithValue(notes),
          idGeneratorProvider.overrideWithValue(SequenceIdGenerator()),
          clockProvider.overrideWithValue(() => fixedNow),
          signedInOverride(),
        ],
        analytics: analytics,
      );
      container.listen(createNoteControllerProvider, (_, _) {});
      container.listen(updateNoteControllerProvider, (_, _) {});
    });

    test('creating a note logs note_saved once', () async {
      await container
          .read(createNoteControllerProvider.notifier)
          .create(const NoteDraft(title: 'Private title', content: 'Secret'));
      await pumpEventQueue();
      expect(analytics.events, ['note_saved']);
    });

    test('saving an edit logs nothing (new notes only)', () async {
      final original = buildNote(id: 'n', title: 'Old');
      notes.seed([original]);
      await container
          .read(updateNoteControllerProvider.notifier)
          .save(original, const NoteDraft(title: 'New'));
      await pumpEventQueue();
      expect(analytics.events, isEmpty);
    });

    test('a failed save logs nothing', () async {
      notes.nextMutationError = const LocalDatabaseFailure();
      final created = await container
          .read(createNoteControllerProvider.notifier)
          .create(const NoteDraft(title: 'T'));
      await pumpEventQueue();
      expect(created, isNull);
      expect(analytics.events, isEmpty);
    });

    test('analytics being unavailable never stops a save', () async {
      final noFirebase = FirebaseAppAnalytics(
        const NoOpLogger(),
        analytics: () => throw StateError('No Firebase App'),
      );
      final c = createContainer(
        overrides: [
          noteRepositoryProvider.overrideWithValue(notes),
          idGeneratorProvider.overrideWithValue(SequenceIdGenerator()),
          clockProvider.overrideWithValue(() => fixedNow),
          signedInOverride(),
        ],
        analytics: noFirebase,
      );
      c.listen(createNoteControllerProvider, (_, _) {});

      final created = await c
          .read(createNoteControllerProvider.notifier)
          .create(const NoteDraft(title: 'T'));
      expect(created, isNotNull);
      expect(c.read(createNoteControllerProvider).hasError, isFalse);
    });
  });

  test('FirebaseAppAnalytics never throws when Analytics fails', () {
    final analytics = FirebaseAppAnalytics(
      const NoOpLogger(),
      analytics: () => throw StateError('No Firebase App'),
    );
    expect(() => analytics.logLogin(LoginMethod.email), returnsNormally);
    expect(analytics.logNoteSaved, returnsNormally);
    expect(FirebaseAppAnalytics.noteSavedEvent, 'note_saved');
  });
}
