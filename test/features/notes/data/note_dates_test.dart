import 'package:flutter_test/flutter_test.dart';
import 'package:notevalult/core/database/local_database_exception_mapper.dart';
import 'package:notevalult/features/folders/data/datasources/drift_folder_local_data_source.dart';
import 'package:notevalult/features/folders/data/repositories/folder_repository_impl.dart';
import 'package:notevalult/features/notes/data/datasources/drift_note_local_data_source.dart';
import 'package:notevalult/features/notes/data/repositories/note_repository_impl.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/sequence_id_generator.dart';
import '../../../helpers/test_database.dart';

/// Date strategy: UTC in the database and domain; the presentation layer
/// converts with `toLocal()` only when displaying.
void main() {
  late NoteRepositoryImpl notes;
  late FolderRepositoryImpl folders;

  setUp(() {
    final db = createTestDatabase();
    notes = NoteRepositoryImpl(
      local: DriftNoteLocalDataSource(
        database: db,
        idGenerator: SequenceIdGenerator(),
      ),
      exceptionMapper: const LocalDatabaseExceptionMapper(),
      // A local-time clock, like DateTime.now() in production.
      clock: () => DateTime(2026, 6, 15, 9, 30),
    );
    folders = FolderRepositoryImpl(
      local: DriftFolderLocalDataSource(database: db),
      exceptionMapper: const LocalDatabaseExceptionMapper(),
    );
  });

  test('notes come back from storage as UTC at the same instant', () async {
    final localTime = DateTime(2026, 3, 1, 8, 15, 30, 250); // local zone
    await notes.createNote(
      buildNote(createdAt: localTime, updatedAt: localTime),
    );

    final stored = await notes.getNote('note-1');

    expect(stored.createdAt.isUtc, isTrue);
    expect(stored.updatedAt.isUtc, isTrue);
    expect(stored.createdAt.isAtSameMomentAs(localTime), isTrue);
    expect(stored.createdAt.millisecond, 250);
  });

  test('updatedAt stamped from a local clock is still stored as UTC', () async {
    await notes.createNote(buildNote());

    final updated = await notes.updateNote(buildNote(title: 'New'));

    expect(updated.updatedAt.isUtc, isTrue);
    expect(
      updated.updatedAt.isAtSameMomentAs(DateTime(2026, 6, 15, 9, 30)),
      isTrue,
    );
  });

  test('folders come back as UTC too', () async {
    await folders.createFolder(buildFolder());

    expect((await folders.getFolder('folder-1')).createdAt.isUtc, isTrue);
  });

  test(
    'presentation can convert the UTC value to local time to display',
    () async {
      await notes.createNote(
        buildNote(createdAt: DateTime.utc(2026, 1, 1, 12)),
      );

      final shown = (await notes.getNote('note-1')).createdAt.toLocal();

      expect(shown.isUtc, isFalse);
      expect(shown.isAtSameMomentAs(DateTime.utc(2026, 1, 1, 12)), isTrue);
    },
  );
}
