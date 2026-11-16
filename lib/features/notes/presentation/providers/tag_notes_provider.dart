import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../tags/presentation/providers/tags_provider.dart';
import '../../domain/entities/note.dart';
import 'visible_notes_provider.dart';

part 'tag_notes_provider.g.dart';

/// Notes that use the tag [tagId], in list order. Derived from
/// [visibleNotesProvider] and [tagsProvider] (notes store tag names; tags
/// map ids to names, matched ignoring case), so renaming a tag keeps the
/// filter working. One instance per tag id, auto-disposed when unused.
@riverpod
AsyncValue<List<Note>> tagNotes(Ref ref, String tagId) {
  final tags = ref.watch(tagsProvider).value ?? const [];
  final name = tags
      .where((t) => t.id == tagId)
      .map((t) => t.name.toLowerCase())
      .firstOrNull;
  return ref
      .watch(visibleNotesProvider)
      .whenData(
        (notes) => name == null
            ? const <Note>[]
            : [
                for (final note in notes)
                  if (note.tags.any((t) => t.toLowerCase() == name)) note,
              ],
      );
}
