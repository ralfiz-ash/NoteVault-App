import 'package:flutter_test/flutter_test.dart';
import 'package:notevalult/core/database/local_database_exception_mapper.dart';
import 'package:notevalult/core/errors/failure.dart';
import 'package:notevalult/features/notes/data/datasources/drift_note_local_data_source.dart';
import 'package:notevalult/features/notes/data/models/note_model.dart';
import 'package:notevalult/features/tags/data/datasources/drift_tag_local_data_source.dart';
import 'package:notevalult/features/tags/data/repositories/tag_repository_impl.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/sequence_id_generator.dart';
import '../../../helpers/test_database.dart';

void main() {
  late DriftNoteLocalDataSource notes;
  late TagRepositoryImpl repository;

  setUp(() {
    final db = createTestDatabase();
    notes = DriftNoteLocalDataSource(
      database: db,
      idGenerator: SequenceIdGenerator(),
    );
    repository = TagRepositoryImpl(
      local: DriftTagLocalDataSource(database: db),
      exceptionMapper: const LocalDatabaseExceptionMapper(),
    );
  });

  test('tags created through notes are listed by name', () async {
    await notes.insertNote(
      NoteModel.fromEntity(buildNote(tags: ['zeta', 'Alpha'])),
    );

    final tags = await repository.getTags();
    expect(tags.map((t) => t.name), ['Alpha', 'zeta']);
  });

  test('deleting a tag removes it from the notes that use it', () async {
    await notes.insertNote(NoteModel.fromEntity(buildNote(tags: ['a', 'b'])));
    final tagA = (await repository.getTags()).firstWhere((t) => t.name == 'a');

    await repository.deleteTag(tagA.id);

    expect((await notes.getNote('note-1'))!.tags, ['b']);
    await expectLater(
      repository.deleteTag(tagA.id),
      throwsA(isA<NotFoundFailure>()),
    );
  });

  group('tag lifecycle: tags are independent and reusable', () {
    test('removing a tag from a note keeps the tag', () async {
      await notes.insertNote(
        NoteModel.fromEntity(buildNote(tags: ['Flutter', 'dart'])),
      );

      // Edit the note so it no longer uses "Flutter".
      await notes.updateNote(NoteModel.fromEntity(buildNote(tags: ['dart'])));

      expect((await notes.getNote('note-1'))!.tags, ['dart']);
      expect((await repository.getTags()).map((t) => t.name), [
        'dart',
        'Flutter',
      ]);
    });

    test('deleting a note keeps its tags', () async {
      await notes.insertNote(NoteModel.fromEntity(buildNote(tags: ['a'])));

      await notes.deleteNote('note-1');

      expect((await repository.getTags()).map((t) => t.name), ['a']);
    });

    test('an unused tag can be attached to another note later', () async {
      await notes.insertNote(NoteModel.fromEntity(buildNote(tags: ['reuse'])));
      final original = (await repository.getTags()).single;
      await notes.updateNote(NoteModel.fromEntity(buildNote()));

      await notes.insertNote(
        NoteModel.fromEntity(buildNote(id: 'note-2', tags: ['REUSE'])),
      );

      // Same tag entity (same id), not a duplicate.
      final tags = await repository.getTags();
      expect(tags, hasLength(1));
      expect(tags.single.id, original.id);
    });

    test('a tag is only removed by an explicit deleteTag', () async {
      await notes.insertNote(NoteModel.fromEntity(buildNote(tags: ['gone'])));
      await notes.updateNote(NoteModel.fromEntity(buildNote()));
      final tag = (await repository.getTags()).single;

      await repository.deleteTag(tag.id);

      expect(await repository.getTags(), isEmpty);
    });
  });
}
