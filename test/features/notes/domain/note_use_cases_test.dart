import 'package:flutter_test/flutter_test.dart';
import 'package:notevalult/core/errors/failure.dart';
import 'package:notevalult/core/usecase/usecase.dart';
import 'package:notevalult/features/notes/domain/entities/note_draft.dart';
import 'package:notevalult/features/notes/domain/usecases/create_note.dart';
import 'package:notevalult/features/notes/domain/usecases/delete_note.dart';
import 'package:notevalult/features/notes/domain/usecases/get_note.dart';
import 'package:notevalult/features/notes/domain/usecases/get_notes.dart';
import 'package:notevalult/features/notes/domain/usecases/update_note.dart';
import 'package:notevalult/features/notes/domain/validation/note_validators.dart';

import '../../../helpers/fake_repositories.dart';
import '../../../helpers/fixtures.dart';
import '../../../helpers/sequence_id_generator.dart';

void main() {
  late FakeNoteRepository repo;
  setUp(() => repo = FakeNoteRepository(clock: () => DateTime.utc(2026, 12)));

  CreateNote create() => CreateNote(
    repo,
    SequenceIdGenerator(),
    () => DateTime(2026, 11, 16, 10), // local clock, like DateTime.now()
  );

  group('CreateNote', () {
    test(
      'creates with a new id, UTC timestamps and normalized input',
      () async {
        final note = await create()(
          const NoteDraft(
            title: '  Shopping  ',
            content: 'milk\n',
            folderId: 'f1',
            tags: [' Home ', 'home', '', 'errands'],
          ),
        );

        expect(note.id, 'id-1');
        expect(note.title, 'Shopping');
        expect(note.content, 'milk\n'); // content kept as typed
        expect(note.folderId, 'f1');
        expect(note.tags, ['Home', 'errands']);
        expect(note.createdAt.isUtc, isTrue);
        expect(note.createdAt, note.updatedAt);
        expect(
          note.createdAt.isAtSameMomentAs(DateTime(2026, 11, 16, 10)),
          isTrue,
        );
        expect(repo.calls, ['create:id-1']);
      },
    );

    test('empty content is allowed', () async {
      final note = await create()(const NoteDraft(title: 'Only a title'));
      expect(note.content, '');
    });

    test('a missing title is rejected before the repository', () async {
      await expectLater(
        create()(const NoteDraft(title: '   ')),
        throwsA(
          isA<ValidationFailure>().having(
            (f) => f.fieldErrors['title'],
            'title error',
            'Title is required',
          ),
        ),
      );
      expect(repo.calls, isEmpty);
    });

    test('repository failure propagates', () async {
      repo.nextMutationError = const LocalDatabaseFailure();
      await expectLater(
        create()(const NoteDraft(title: 'T')),
        throwsA(isA<LocalDatabaseFailure>()),
      );
    });
  });

  group('GetNotes', () {
    test('returns notes', () async {
      repo.seed([buildNote(id: 'a'), buildNote(id: 'b')]);
      expect((await GetNotes(repo)(const NoParams())).length, 2);
    });

    test('returns an empty list when there are none', () async {
      expect(await GetNotes(repo)(const NoParams()), isEmpty);
    });

    test('repository failure propagates', () async {
      final failing = _FailingReadRepository();
      await expectLater(
        GetNotes(failing)(const NoParams()),
        throwsA(isA<LocalDatabaseFailure>()),
      );
    });
  });

  group('GetNote', () {
    test('found', () async {
      repo.seed([buildNote(id: 'a', title: 'A')]);
      expect((await GetNote(repo)('a')).title, 'A');
    });

    test('not found', () async {
      await expectLater(GetNote(repo)('x'), throwsA(isA<NotFoundFailure>()));
    });

    test('repository failure propagates', () async {
      await expectLater(
        GetNote(_FailingReadRepository())('a'),
        throwsA(isA<LocalDatabaseFailure>()),
      );
    });
  });

  group('UpdateNote', () {
    test('saves normalized changes; id and createdAt kept', () async {
      final original = buildNote(id: 'n', createdAt: DateTime.utc(2026));
      repo.seed([original]);

      final saved = await UpdateNote(repo)(
        original.copyWith(title: '  New  ', tags: ['a', 'A']),
      );

      expect(saved.id, 'n');
      expect(saved.title, 'New');
      expect(saved.tags, ['a']);
      expect(saved.createdAt, DateTime.utc(2026));
      expect(saved.updatedAt, DateTime.utc(2026, 12));
    });

    test('invalid title is rejected', () async {
      repo.seed([buildNote(id: 'n')]);
      await expectLater(
        UpdateNote(repo)(buildNote(id: 'n', title: '')),
        throwsA(isA<ValidationFailure>()),
      );
      expect(repo.calls, isEmpty);
    });

    test('repository failure propagates', () async {
      repo.seed([buildNote(id: 'n')]);
      repo.nextMutationError = const LocalDatabaseFailure();
      await expectLater(
        UpdateNote(repo)(buildNote(id: 'n', title: 'T')),
        throwsA(isA<LocalDatabaseFailure>()),
      );
    });
  });

  group('DeleteNote', () {
    test('deletes', () async {
      repo.seed([buildNote(id: 'n')]);
      await DeleteNote(repo)('n');
      expect(await repo.getNotes(), isEmpty);
    });

    test('repository failure propagates', () async {
      repo.seed([buildNote(id: 'n')]);
      repo.nextMutationError = const LocalDatabaseFailure();
      await expectLater(
        DeleteNote(repo)('n'),
        throwsA(isA<LocalDatabaseFailure>()),
      );
    });
  });

  group('NoteDraft', () {
    test('equality covers every editable field', () {
      const a = NoteDraft(title: 't', content: 'c', folderId: 'f', tags: ['x']);
      expect(
        a,
        const NoteDraft(title: 't', content: 'c', folderId: 'f', tags: ['x']),
      );
      expect(a == a.copyWith(title: 'u'), isFalse);
      expect(a == a.copyWith(content: 'd'), isFalse);
      expect(a == a.copyWith(folderId: () => null), isFalse);
      expect(a == a.copyWith(tags: ['y']), isFalse);
    });

    test('validators', () {
      expect(NoteValidators.title(''), 'Title is required');
      expect(NoteValidators.title('x' * 201), contains('at most'));
      expect(NoteValidators.tag(' '), 'Tag cannot be empty');
      expect(NoteValidators.tagCount(List.filled(21, 't')), isNotNull);
    });
  });
}

class _FailingReadRepository extends FakeNoteRepository {
  @override
  Future<List<Never>> getNotes() async => throw const LocalDatabaseFailure();

  @override
  Future<Never> getNote(String id) async => throw const LocalDatabaseFailure();
}
