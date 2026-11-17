import 'package:flutter_test/flutter_test.dart';
import 'package:notevalult/core/errors/failure.dart';
import 'package:notevalult/features/folders/domain/usecases/create_folder.dart';
import 'package:notevalult/features/folders/domain/usecases/rename_folder.dart';
import 'package:notevalult/features/notes/domain/usecases/note_tag_usecases.dart';
import 'package:notevalult/features/tags/domain/entities/tag.dart';
import 'package:notevalult/features/tags/domain/entities/tag_colors.dart';
import 'package:notevalult/features/tags/domain/usecases/create_tag.dart';

import '../../../helpers/fake_repositories.dart';
import '../../../helpers/fixtures.dart';
import '../../../helpers/sequence_id_generator.dart';

void main() {
  group('tag use cases', () {
    late FakeTagRepository repo;
    setUp(() => repo = FakeTagRepository());

    test('CreateTag stores the trimmed name and chosen colour', () async {
      final tag = await CreateTag(repo, SequenceIdGenerator())(
        const CreateTagParams(name: ' Urgent ', colorValue: '#c0392b'),
      );
      expect(tag, const Tag(id: 'id-1', name: 'Urgent', colorValue: '#C0392B'));
    });

    test('CreateTag rejects empty names and invalid colours', () async {
      final create = CreateTag(repo, SequenceIdGenerator());
      await expectLater(
        create(const CreateTagParams(name: ' ', colorValue: '#C0392B')),
        throwsA(isA<ValidationFailure>()),
      );
      await expectLater(
        create(const CreateTagParams(name: 'x', colorValue: 'blue')),
        throwsA(isA<ValidationFailure>()),
      );
      expect(await repo.getTags(), isEmpty);
    });

    test('UpdateTag changes name and colour', () async {
      await repo.createTag(const Tag(id: 't', name: 'A'));
      final updated = await UpdateTag(repo)(
        const Tag(id: 't', name: 'B', colorValue: '#27AE60'),
      );
      expect(updated.colorValue, '#27AE60');
      expect((await repo.getTags()).single.name, 'B');
    });

    test('palette values are valid; normalize falls back to default', () {
      expect(TagColors.palette.every(TagColors.isValid), isTrue);
      expect(TagColors.palette.first, TagColors.defaultValue);
      expect(TagColors.normalize('nope'), TagColors.defaultValue);
      expect(TagColors.normalize('#abcdef'), '#ABCDEF');
    });
  });

  group('folder use cases', () {
    late FakeFolderRepository repo;
    setUp(
      () => repo = FakeFolderRepository([buildFolder(id: 'f', name: 'Old')]),
    );

    test('CreateFolder', () async {
      final folder = await CreateFolder(
        repo,
        SequenceIdGenerator(),
        () => fixedNow,
      )('  Projects ');
      expect(folder.name, 'Projects');
    });

    test('RenameFolder validates and renames', () async {
      await expectLater(
        RenameFolder(repo)(buildFolder(id: 'f', name: '')),
        throwsA(isA<ValidationFailure>()),
      );
      final renamed = await RenameFolder(repo)(
        buildFolder(id: 'f', name: 'New'),
      );
      expect(renamed.name, 'New');
    });

    test('DeleteFolder', () async {
      await DeleteFolder(repo)('f');
      expect(await repo.getFolders(), isEmpty);
    });
  });

  group('note tag use cases', () {
    late FakeNoteRepository notes;
    setUp(() {
      notes = FakeNoteRepository()
        ..seed([
          buildNote(id: 'n', tags: ['a']),
        ]);
    });

    test('AddTagToNote adds once (ignoring case)', () async {
      await AddTagToNote(notes)(const NoteTagParams(noteId: 'n', tagName: 'b'));
      await AddTagToNote(notes)(const NoteTagParams(noteId: 'n', tagName: 'B'));
      expect((await notes.getNote('n')).tags, ['a', 'b']);
    });

    test('RemoveTagFromNote removes only the link', () async {
      await RemoveTagFromNote(notes)(
        const NoteTagParams(noteId: 'n', tagName: 'A'),
      );
      expect((await notes.getNote('n')).tags, isEmpty);
    });
  });
}
