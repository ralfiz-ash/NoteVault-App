import 'package:flutter_test/flutter_test.dart';
import 'package:notevalult/features/folders/data/datasources/drift_folder_local_data_source.dart';
import 'package:notevalult/features/folders/data/models/folder_model.dart';
import 'package:notevalult/features/notes/data/datasources/drift_note_local_data_source.dart';
import 'package:notevalult/features/notes/data/models/note_model.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/sequence_id_generator.dart';
import '../../../helpers/test_database.dart';

void main() {
  late DriftNoteLocalDataSource source;
  late DriftFolderLocalDataSource folders;

  setUp(() {
    final db = createTestDatabase();
    source = DriftNoteLocalDataSource(
      database: db,
      idGenerator: SequenceIdGenerator(),
    );
    folders = DriftFolderLocalDataSource(database: db);
  });

  NoteModel model({
    String id = 'note-1',
    List<String> tags = const [],
    String? folderId,
    DateTime? updatedAt,
  }) => NoteModel.fromEntity(
    buildNote(id: id, tags: tags, folderId: folderId, updatedAt: updatedAt),
  );

  test('insert then get returns the stored note', () async {
    await source.insertNote(model(tags: ['b', 'a']));

    final stored = await source.getNote('note-1');
    expect(stored, isNotNull);
    expect(stored!.title, 'Title');
    expect(stored.tags, ['a', 'b']); // sorted by name
  });

  test('getNote returns null for an unknown id', () async {
    expect(await source.getNote('missing'), isNull);
  });

  test('getNotes returns newest edit first', () async {
    await source.insertNote(model(id: 'old', updatedAt: DateTime.utc(2026, 1)));
    await source.insertNote(model(id: 'new', updatedAt: DateTime.utc(2026, 3)));
    await source.insertNote(model(id: 'mid', updatedAt: DateTime.utc(2026, 2)));

    final notes = await source.getNotes();
    expect(notes.map((n) => n.id), ['new', 'mid', 'old']);
  });

  test('inserting a duplicate id throws', () async {
    await source.insertNote(model());
    await expectLater(source.insertNote(model()), throwsA(anything));
  });

  test('update replaces fields and tags; unknown id returns false', () async {
    await source.insertNote(model(tags: ['a', 'b']));

    final changed = NoteModel.fromEntity(
      buildNote(title: 'New', content: 'Body', tags: ['b', 'c']),
    );
    expect(await source.updateNote(changed), isTrue);

    final stored = (await source.getNote('note-1'))!;
    expect(stored.title, 'New');
    expect(stored.tags, ['b', 'c']);
    expect(await source.updateNote(model(id: 'missing')), isFalse);
  });

  test('delete removes the note; unknown id returns false', () async {
    await source.insertNote(model());

    expect(await source.deleteNote('note-1'), isTrue);
    expect(await source.getNote('note-1'), isNull);
    expect(await source.deleteNote('note-1'), isFalse);
  });

  group('tags', () {
    test('are trimmed, de-duplicated ignoring case, and shared', () async {
      await source.insertNote(model(tags: [' Work ', 'work', '', 'Idea']));
      await source.insertNote(model(id: 'note-2', tags: ['WORK']));

      expect((await source.getNote('note-1'))!.tags, ['Idea', 'Work']);
      // Reuses the existing "Work" tag (first spelling wins).
      expect((await source.getNote('note-2'))!.tags, ['Work']);
    });
  });

  group('folders', () {
    test('a note can reference an existing folder', () async {
      await folders.insertFolder(FolderModel.fromEntity(buildFolder(id: 'f1')));
      await source.insertNote(model(folderId: 'f1'));

      expect((await source.getNote('note-1'))!.folderId, 'f1');
    });

    test('a note cannot reference a folder that does not exist', () async {
      await expectLater(
        source.insertNote(model(folderId: 'ghost')),
        throwsA(anything),
      );
    });

    test('deleting a folder keeps its notes without a folder', () async {
      await folders.insertFolder(FolderModel.fromEntity(buildFolder(id: 'f1')));
      await source.insertNote(model(folderId: 'f1'));

      await folders.deleteFolder('f1');

      final stored = await source.getNote('note-1');
      expect(stored, isNotNull);
      expect(stored!.folderId, isNull);
    });
  });

  test('watchNotes emits the current notes and then every change', () async {
    final emissions = <List<String>>[];
    final sub = source.watchNotes().listen(
      (notes) => emissions.add([for (final n in notes) n.id]),
    );
    addTearDown(sub.cancel);

    await pumpEventQueue();
    await source.insertNote(model());
    await pumpEventQueue();
    await source.deleteNote('note-1');
    await pumpEventQueue();

    expect(emissions.first, isEmpty);
    expect(emissions, contains(equals(['note-1'])));
    expect(emissions.last, isEmpty);
  });
}
