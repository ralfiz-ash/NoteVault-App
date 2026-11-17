import 'package:flutter_test/flutter_test.dart';
import 'package:notevalult/features/notes/domain/entities/note.dart';
import 'package:notevalult/features/notes/domain/entities/note_query.dart';
import 'package:notevalult/features/notes/domain/entities/note_sort.dart';

import '../../../helpers/fixtures.dart';

void main() {
  final flutterTitle = buildNote(id: 't', title: 'Flutter Architecture');
  final flutterBody = buildNote(
    id: 'c',
    title: 'Learning',
    content: 'Learning flutter Riverpod',
  );
  final other = buildNote(id: 'o', title: 'Groceries', content: 'milk');

  List<String> ids(NoteQuery q, List<Note> notes) => [
    for (final n in q.apply(notes)) n.id,
  ];

  group('search', () {
    final notes = [flutterTitle, flutterBody, other];
    final byId = const NoteQuery(sort: NoteSort(field: NoteSortField.title));

    test('matches title and content, case-insensitively', () {
      expect(ids(const NoteQuery(search: 'FLUTTER'), notes).toSet(), {
        't',
        'c',
      });
    });

    test('partial matches', () {
      expect(ids(const NoteQuery(search: 'rocer'), notes), ['o']);
    });

    test('no match', () {
      expect(ids(const NoteQuery(search: 'kotlin'), notes), isEmpty);
    });

    test('empty or blank search matches everything', () {
      expect(ids(const NoteQuery(search: '  '), notes), hasLength(3));
      expect(ids(byId, notes), hasLength(3));
    });
  });

  group('folder', () {
    final notes = [
      buildNote(id: 'w1', folderId: 'work'),
      buildNote(id: 'w2', folderId: 'work'),
      buildNote(id: 'p1', folderId: 'personal'),
      buildNote(id: 'n1'),
    ];

    test('all folders', () {
      expect(ids(const NoteQuery(), notes), hasLength(4));
    });

    test('a folder with several notes', () {
      expect(ids(const NoteQuery(folder: InFolder('work')), notes).toSet(), {
        'w1',
        'w2',
      });
    });

    test('no folder', () {
      expect(ids(const NoteQuery(folder: NoFolder()), notes), ['n1']);
    });

    test('empty folder', () {
      expect(ids(const NoteQuery(folder: InFolder('empty')), notes), isEmpty);
    });
  });

  group('tag', () {
    final notes = [
      buildNote(id: 'a', tags: ['Flutter', 'work']),
      buildNote(id: 'b', tags: ['work']),
      buildNote(id: 'c'),
    ];

    test('specific tag, ignoring case, including notes with several tags', () {
      expect(ids(const NoteQuery(tagName: 'flutter'), notes), ['a']);
      expect(ids(const NoteQuery(tagName: 'WORK'), notes).toSet(), {'a', 'b'});
    });

    test('notes without tags never match a tag filter', () {
      expect(
        ids(const NoteQuery(tagName: 'work'), notes),
        isNot(contains('c')),
      );
    });

    test('a tag no note uses gives an empty result', () {
      expect(ids(const NoteQuery(tagName: 'unused'), notes), isEmpty);
    });
  });

  group('sort', () {
    final a = buildNote(
      id: 'a',
      title: 'banana',
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 3, 1),
    );
    final b = buildNote(
      id: 'b',
      title: 'Apple',
      createdAt: DateTime.utc(2026, 2, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
    );
    final c = buildNote(
      id: 'c',
      title: 'cherry',
      createdAt: DateTime.utc(2026, 3, 1),
      updatedAt: DateTime.utc(2026, 2, 1),
    );
    final notes = [a, b, c];
    List<String> sorted(NoteSortField field, {required bool asc}) => ids(
      NoteQuery(
        sort: NoteSort(field: field, ascending: asc),
      ),
      notes,
    );

    test('created date', () {
      expect(sorted(NoteSortField.created, asc: true), ['a', 'b', 'c']);
      expect(sorted(NoteSortField.created, asc: false), ['c', 'b', 'a']);
    });

    test('updated date', () {
      expect(sorted(NoteSortField.updated, asc: true), ['b', 'c', 'a']);
      expect(sorted(NoteSortField.updated, asc: false), ['a', 'c', 'b']);
    });

    test('title (ignoring case)', () {
      expect(sorted(NoteSortField.title, asc: true), ['b', 'a', 'c']);
      expect(sorted(NoteSortField.title, asc: false), ['c', 'a', 'b']);
    });

    test('UTC and local values of the same instant compare equal', () {
      final local = DateTime.utc(2026, 5, 1).toLocal();
      final x = buildNote(id: 'x', updatedAt: local);
      final y = buildNote(id: 'y', updatedAt: DateTime.utc(2026, 5, 1));
      // Equal instants: tie broken by id, stable either way.
      expect(ids(const NoteQuery(sort: NoteSort(ascending: true)), [y, x]), [
        'x',
        'y',
      ]);
    });

    test('the input list is not modified', () {
      final input = [a, b, c];
      const NoteQuery(sort: NoteSort(field: NoteSortField.title)).apply(input);
      expect(input, [a, b, c]);
    });
  });

  group('combined (AND)', () {
    final notes = [
      buildNote(
        id: 'hit',
        title: 'Flutter plan',
        folderId: 'work',
        tags: ['Important'],
      ),
      buildNote(id: 'noTag', title: 'Flutter plan', folderId: 'work'),
      buildNote(
        id: 'otherFolder',
        title: 'Flutter plan',
        folderId: 'home',
        tags: ['Important'],
      ),
      buildNote(
        id: 'noSearch',
        title: 'Budget',
        folderId: 'work',
        tags: ['Important'],
      ),
    ];

    test('search + folder', () {
      expect(
        ids(
          const NoteQuery(search: 'flutter', folder: InFolder('work')),
          notes,
        ).toSet(),
        {'hit', 'noTag'},
      );
    });

    test('search + tag', () {
      expect(
        ids(
          const NoteQuery(search: 'flutter', tagName: 'important'),
          notes,
        ).toSet(),
        {'hit', 'otherFolder'},
      );
    });

    test('folder + tag', () {
      expect(
        ids(
          const NoteQuery(folder: InFolder('work'), tagName: 'Important'),
          notes,
        ).toSet(),
        {'hit', 'noSearch'},
      );
    });

    test('search + folder + tag', () {
      expect(
        ids(
          const NoteQuery(
            search: 'flutter',
            folder: InFolder('work'),
            tagName: 'Important',
          ),
          notes,
        ),
        ['hit'],
      );
    });

    test('hasFilters reflects only active conditions', () {
      expect(const NoteQuery().hasFilters, isFalse);
      expect(
        const NoteQuery(sort: NoteSort(ascending: true)).hasFilters,
        isFalse,
      );
      expect(const NoteQuery(search: 'x').hasFilters, isTrue);
      expect(const NoteQuery(folder: NoFolder()).hasFilters, isTrue);
      expect(const NoteQuery(tagName: 't').hasFilters, isTrue);
    });
  });
}
