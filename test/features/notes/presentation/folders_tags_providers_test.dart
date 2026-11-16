import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderListenable;
import 'package:flutter_test/flutter_test.dart';
import 'package:notevalult/app/di/repository_providers.dart';
import 'package:notevalult/features/folders/presentation/providers/folders_provider.dart';
import 'package:notevalult/features/notes/domain/entities/note.dart';
import 'package:notevalult/features/notes/presentation/providers/folder_notes_provider.dart';
import 'package:notevalult/features/notes/presentation/providers/notes_filter_provider.dart';
import 'package:notevalult/features/notes/presentation/providers/tag_notes_provider.dart';
import 'package:notevalult/features/notes/presentation/state/notes_filter.dart';
import 'package:notevalult/features/tags/domain/entities/tag.dart';
import 'package:notevalult/features/tags/presentation/providers/tags_provider.dart';

import '../../../helpers/fake_repositories.dart';
import '../../../helpers/fixtures.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  late FakeNoteRepository notes;
  late FakeFolderRepository folders;
  late FakeTagRepository tags;
  late ProviderContainer container;

  setUp(() async {
    notes = FakeNoteRepository()
      ..seed([
        buildNote(id: 'a1', folderId: 'A', tags: ['work']),
        buildNote(id: 'a2', folderId: 'A'),
        buildNote(id: 'b1', folderId: 'B', tags: ['Work', 'home']),
        buildNote(id: 'n1'),
      ]);
    folders = FakeFolderRepository([
      buildFolder(id: 'A', name: 'Alpha'),
      buildFolder(id: 'B', name: 'Beta'),
    ]);
    tags = FakeTagRepository(const [
      Tag(id: 'tw', name: 'Work', colorValue: '#2980B9'),
      Tag(id: 'th', name: 'home'),
    ]);
    container = createContainer(
      overrides: [
        noteRepositoryProvider.overrideWithValue(notes),
        folderRepositoryProvider.overrideWithValue(folders),
        tagRepositoryProvider.overrideWithValue(tags),
        signedInOverride(),
      ],
    );
    container
      ..listen(folderNoteCountsProvider, (_, _) {})
      ..listen(tagsByNameProvider, (_, _) {});
    await readFuture(container, foldersProvider);
  });

  Future<List<String>> ids(
    ProviderListenable<AsyncValue<List<Note>>> p,
  ) async => [for (final n in await readFuture(container, p)) n.id];

  test('folder family instances are independent', () async {
    expect((await ids(folderNotesProvider('A'))).toSet(), {'a1', 'a2'});
    expect(await ids(folderNotesProvider('B')), ['b1']);
    expect(await ids(folderNotesProvider(null)), ['n1']);
    expect(folderNotesProvider('A'), isNot(folderNotesProvider('B')));
  });

  test('tag filter matches names ignoring case', () async {
    expect((await ids(tagNotesProvider('tw'))).toSet(), {'a1', 'b1'});
    expect(await ids(tagNotesProvider('th')), ['b1']);
    expect(await ids(tagNotesProvider('missing')), isEmpty);
  });

  test(
    'folder counts follow create, move, delete and folder deletion',
    () async {
      await pumpEventQueue();
      expect(container.read(folderNoteCountsProvider), {
        'A': 2,
        'B': 1,
        null: 1,
      });

      await notes.createNote(buildNote(id: 'a3', folderId: 'A'));
      await notes.updateNote(buildNote(id: 'b1', folderId: 'A'));
      await notes.deleteNote('n1');
      await pumpEventQueue();
      expect(container.read(folderNoteCountsProvider), {'A': 4});

      // Folder deleted: its notes become "No folder" (as the database does).
      for (final id in ['a1', 'a2', 'a3', 'b1']) {
        final note = await notes.getNote(id);
        notes.seed([note.copyWith(folderId: () => null)]);
      }
      await pumpEventQueue();
      expect(container.read(folderNoteCountsProvider), {null: 4});
    },
  );

  test('editing a tag colour updates the shared tag state', () async {
    await readFuture(container, tagsProvider);
    await pumpEventQueue(); // let the live tag stream subscribe
    expect(container.read(tagsByNameProvider)['work']!.colorValue, '#2980B9');

    container.listen(tagActionsProvider, (_, _) {});
    await container
        .read(tagActionsProvider.notifier)
        .edit(const Tag(id: 'tw', name: 'Work', colorValue: '#C0392B'));
    await pumpEventQueue();

    expect(container.read(tagsByNameProvider)['work']!.colorValue, '#C0392B');
  });

  test('the list filter switches between family instances', () async {
    container.listen(filteredNotesProvider, (_, _) {});
    final filter = container.read(notesFilterControllerProvider.notifier);

    filter.show(const FolderFilter('B'));
    expect(await ids(filteredNotesProvider), ['b1']);
    filter.show(const TagFilter('th'));
    expect(await ids(filteredNotesProvider), ['b1']);
    filter.show(const AllNotes());
    expect((await ids(filteredNotesProvider)).length, 4);
  });
}
