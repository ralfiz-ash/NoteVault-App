import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../app/di/database_providers.dart';
import '../../../../app/di/repository_providers.dart';
import '../../../../app/di/session_providers.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../notes/presentation/providers/visible_notes_provider.dart';
import '../../domain/entities/tag.dart';
import '../../domain/usecases/create_tag.dart';
import '../../domain/usecases/observe_tags.dart';

part 'tags_provider.g.dart';

/// The signed-in user's tags (by name), live, including tags no note uses
/// (tags are independent). The single source of every tag's colour. Empty
/// while signed out.
///
/// keepAlive: read by every tag chip (list, note, editor, filters, tag
/// screen); one database watch for the session instead of one per screen.
@Riverpod(keepAlive: true)
Stream<List<Tag>> tags(Ref ref) {
  final userId = ref.watch(
    currentUserIdProvider.select((session) => session.value),
  );
  if (userId == null) return Stream.value(const <Tag>[]);
  return ObserveTags(ref.watch(tagRepositoryProvider))(const NoParams());
}

/// Lower-case tag name -> tag, for showing a note's tags (notes store names)
/// with their colour.
@riverpod
Map<String, Tag> tagsByName(Ref ref) => {
  for (final tag in ref.watch(tagsProvider).value ?? const <Tag>[])
    tag.name.toLowerCase(): tag,
};

/// Lower-case tag name -> number of notes using it. Derived in one pass from
/// the same notes the list shows (no query per tag, no stored counts).
@riverpod
Map<String, int> tagNoteCounts(Ref ref) {
  final counts = <String, int>{};
  for (final note in ref.watch(visibleNotesProvider).value ?? const []) {
    for (final tag in note.tags) {
      final key = tag.toLowerCase();
      counts[key] = (counts[key] ?? 0) + 1;
    }
  }
  return counts;
}

@riverpod
CreateTag createTag(Ref ref) =>
    CreateTag(ref.watch(tagRepositoryProvider), ref.watch(idGeneratorProvider));

@riverpod
UpdateTag updateTag(Ref ref) => UpdateTag(ref.watch(tagRepositoryProvider));

@riverpod
DeleteTag deleteTag(Ref ref) => DeleteTag(ref.watch(tagRepositoryProvider));

/// Create / edit / delete tags from the tags screen. State:
/// `AsyncData(null)` idle or done, `AsyncLoading`, `AsyncError(Failure)`.
@riverpod
class TagActions extends _$TagActions {
  @override
  FutureOr<void> build() {}

  Future<Tag?> create({required String name, required String colorValue}) =>
      _run(
        () => ref.read(createTagProvider)(
          CreateTagParams(name: name, colorValue: colorValue),
        ),
      );

  Future<Tag?> edit(Tag tag) => _run(() => ref.read(updateTagProvider)(tag));

  Future<bool> delete(String id) async =>
      await _run<bool>(() async {
        await ref.read(deleteTagProvider)(id);
        return true;
      }) ??
      false;

  /// Ignores a new request while one is running (no double submit).
  Future<T?> _run<T>(Future<T> Function() action) async {
    if (state.isLoading) return null;
    state = const AsyncLoading();
    T? value;
    final result = await AsyncValue.guard(() async {
      value = await action();
    });
    if (ref.mounted) state = result;
    return result.hasError ? null : value;
  }
}
