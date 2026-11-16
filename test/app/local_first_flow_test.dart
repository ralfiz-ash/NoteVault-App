import 'package:flutter_test/flutter_test.dart';
import 'package:notevalult/app/di/core_providers.dart';
import 'package:notevalult/app/di/database_providers.dart';
import 'package:notevalult/app/di/repository_providers.dart';
import 'package:notevalult/core/errors/failure.dart';
import 'package:notevalult/core/logging/app_logger.dart';

import '../helpers/fixtures.dart';
import '../helpers/test_database.dart';
import '../helpers/test_helpers.dart';

/// Wires the real provider chain (database -> data source -> repository) on
/// an in-memory database. No network, Firebase or app database file involved.
void main() {
  test('notes work offline: create, read, update, read, delete', () async {
    var now = fixedNow;
    final container = createContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(createTestDatabase()),
        clockProvider.overrideWithValue(() => now),
        appLoggerProvider.overrideWithValue(const NoOpLogger()),
      ],
    );
    final repository = container.read(noteRepositoryProvider);

    // Create + persist locally
    await repository.createNote(buildNote(title: 'Draft', tags: ['idea']));

    // Read locally
    expect((await repository.getNote('note-1')).title, 'Draft');

    // Update locally
    now = DateTime.utc(2026, 12);
    await repository.updateNote(
      buildNote(title: 'Final', tags: ['idea', 'done']),
    );

    // Read the updated data locally
    final updated = await repository.getNote('note-1');
    expect(updated.title, 'Final');
    expect(updated.tags, ['done', 'idea']);
    expect(updated.updatedAt, now);
    expect(updated.createdAt, DateTime.utc(2026, 1, 1));

    // Delete locally
    await repository.deleteNote('note-1');
    await expectLater(
      repository.getNote('note-1'),
      throwsA(isA<NotFoundFailure>()),
    );
  });

  test('every layer can be replaced with a fake through providers', () {
    final container = createContainer(
      overrides: [appDatabaseProvider.overrideWithValue(createTestDatabase())],
    );

    expect(container.read(noteRepositoryProvider), isNotNull);
    expect(container.read(folderRepositoryProvider), isNotNull);
    expect(container.read(tagRepositoryProvider), isNotNull);
  });
}
