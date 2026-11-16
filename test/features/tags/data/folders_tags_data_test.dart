import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:notevalult/core/database/app_database.dart';
import 'package:notevalult/core/database/local_database_exception_mapper.dart';
import 'package:notevalult/core/errors/failure.dart';
import 'package:notevalult/features/folders/data/datasources/drift_folder_local_data_source.dart';
import 'package:notevalult/features/folders/data/repositories/folder_repository_impl.dart';
import 'package:notevalult/features/notes/data/datasources/drift_note_local_data_source.dart';
import 'package:notevalult/features/notes/data/repositories/note_repository_impl.dart';
import 'package:notevalult/features/tags/data/datasources/drift_tag_local_data_source.dart';
import 'package:notevalult/features/tags/data/repositories/tag_repository_impl.dart';
import 'package:notevalult/features/tags/domain/entities/tag.dart';
import 'package:notevalult/features/tags/domain/entities/tag_colors.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/sequence_id_generator.dart';
import '../../../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  late NoteRepositoryImpl notes;
  late FolderRepositoryImpl folders;
  late TagRepositoryImpl tags;

  setUp(() {
    db = createTestDatabase();
    const mapper = LocalDatabaseExceptionMapper();
    notes = NoteRepositoryImpl(
      local: DriftNoteLocalDataSource(
        database: db,
        idGenerator: SequenceIdGenerator(),
      ),
      exceptionMapper: mapper,
      clock: () => fixedNow,
    );
    folders = FolderRepositoryImpl(
      local: DriftFolderLocalDataSource(database: db),
      exceptionMapper: mapper,
    );
    tags = TagRepositoryImpl(
      local: DriftTagLocalDataSource(database: db),
      exceptionMapper: mapper,
    );
  });

  group('folder deletion', () {
    test(
      'keeps the notes, clears their folder, touches nothing else',
      () async {
        await folders.createFolder(buildFolder(id: 'f1'));
        final inFolder = await notes.createNote(
          buildNote(id: 'a', folderId: 'f1', tags: ['x']),
        );
        await notes.createNote(buildNote(id: 'b', folderId: 'f1'));
        await notes.createNote(buildNote(id: 'c'));

        final emissions = <List<String?>>[];
        final sub = notes.watchNotes().listen(
          (list) => emissions.add([for (final n in list) n.folderId]),
        );
        addTearDown(sub.cancel);
        await pumpEventQueue();

        await folders.deleteFolder('f1');
        await pumpEventQueue();

        final a = await notes.getNote('a');
        expect(a.folderId, isNull);
        expect(a.title, inFolder.title);
        expect(a.tags, inFolder.tags);
        expect(a.createdAt, inFolder.createdAt);
        expect(a.updatedAt, inFolder.updatedAt); // not "edited" by the delete
        expect((await notes.getNotes()), hasLength(3));
        // Watchers saw the change (no app restart needed).
        expect(emissions.last, [null, null, null]);
      },
    );
  });

  group('tags', () {
    test('create with a colour, then load it back', () async {
      await tags.createTag(
        const Tag(id: 't1', name: 'Work', colorValue: '#2980B9'),
      );
      expect((await tags.getTags()).single.colorValue, '#2980B9');
    });

    test('names are unique ignoring case', () async {
      await tags.createTag(const Tag(id: 't1', name: 'Work'));
      await expectLater(
        tags.createTag(const Tag(id: 't2', name: 'WORK')),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('edit name and colour; notes follow the rename', () async {
      await tags.createTag(const Tag(id: 't1', name: 'Work'));
      await notes.createNote(buildNote(id: 'n', tags: ['work']));

      await tags.updateTag(
        const Tag(id: 't1', name: 'Office', colorValue: '#C0392B'),
      );

      expect(await tags.getTags(), [
        const Tag(id: 't1', name: 'Office', colorValue: '#C0392B'),
      ]);
      expect((await notes.getNote('n')).tags, ['Office']);
    });

    test('renaming onto another tag name is rejected', () async {
      await tags.createTag(const Tag(id: 't1', name: 'Work'));
      await tags.createTag(const Tag(id: 't2', name: 'Home'));
      await expectLater(
        tags.updateTag(const Tag(id: 't2', name: 'work')),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('tags created through a note get the default colour', () async {
      await notes.createNote(buildNote(tags: ['new']));
      expect((await tags.getTags()).single.colorValue, TagColors.defaultValue);
    });

    test('an invalid stored colour is shown as the default', () async {
      await db
          .into(db.tags)
          .insert(
            TagsCompanion.insert(
              id: 'bad',
              name: 'Bad',
              color: const Value('red'),
            ),
          );
      expect((await tags.getTags()).single.colorValue, TagColors.defaultValue);
    });

    test(
      'removing a tag from a note keeps the tag; delete unlinks it',
      () async {
        await notes.createNote(buildNote(id: 'n', tags: ['a', 'b']));
        await notes.updateNote(buildNote(id: 'n', tags: ['b']));
        expect((await tags.getTags()).map((t) => t.name), ['a', 'b']);

        final b = (await tags.getTags()).last;
        await tags.deleteTag(b.id);
        expect((await notes.getNote('n')).tags, isEmpty);
      },
    );
  });
}
