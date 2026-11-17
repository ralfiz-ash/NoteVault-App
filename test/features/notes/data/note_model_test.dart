import 'package:flutter_test/flutter_test.dart';
import 'package:notevalult/core/database/app_database.dart';
import 'package:notevalult/features/notes/data/datasources/note_row_mapper.dart';
import 'package:notevalult/features/notes/data/models/note_model.dart';

import '../../../helpers/fixtures.dart';

void main() {
  final note = buildNote(
    folderId: 'folder-1',
    tags: ['work', 'idea'],
    createdAt: DateTime.utc(2026, 1, 2, 3, 4, 5, 678),
    updatedAt: DateTime.utc(2026, 2, 3),
  );

  group('Domain entity <-> data model', () {
    test('round-trips every field', () {
      expect(NoteModel.fromEntity(note).toEntity(), note);
    });

    test('a note without a folder or tags round-trips', () {
      final plain = buildNote();
      expect(NoteModel.fromEntity(plain).toEntity(), plain);
    });
  });

  group('Data model <-> map (future cloud/JSON shape)', () {
    test('round-trips and keeps millisecond precision', () {
      final model = NoteModel.fromEntity(note);
      final restored = NoteModel.fromMap(model.toMap());

      expect(restored.toEntity(), note);
      expect(model.toMap()['createdAt'], isA<int>());
    });
  });

  group('Data model <-> database row', () {
    test('companion carries the model values as epoch milliseconds', () {
      final companion = NoteModel.fromEntity(note).toCompanion();

      expect(companion.id.value, 'note-1');
      expect(companion.folderId.value, 'folder-1');
      expect(companion.createdAt.value, note.createdAt.millisecondsSinceEpoch);
    });

    test('row converts back to a model with the given tags', () {
      final row = NoteRow(
        id: 'n',
        title: 't',
        content: 'c',
        folderId: null,
        createdAt: 1000,
        updatedAt: 2000,
        version: 3,
      );

      final model = row.toModel(['a']);
      expect(model.tags, ['a']);
      expect(model.version, 3);
      expect(
        model.createdAt,
        DateTime.fromMillisecondsSinceEpoch(1000, isUtc: true),
      );
      expect(
        model.updatedAt,
        DateTime.fromMillisecondsSinceEpoch(2000, isUtc: true),
      );
    });
  });
}
