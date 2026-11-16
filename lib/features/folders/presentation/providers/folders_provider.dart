import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../app/di/database_providers.dart';
import '../../../../app/di/repository_providers.dart';
import '../../../../app/di/session_providers.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/folder.dart';
import '../../domain/usecases/create_folder.dart';
import '../../domain/usecases/observe_folders.dart';
import '../../domain/usecases/rename_folder.dart';
import '../../../notes/presentation/providers/notes_provider.dart';

part 'folders_provider.g.dart';

/// The signed-in user's folders (by name), live. Empty while signed out, for
/// the same isolation reason as `notesProvider`.
///
/// keepAlive: shared by the notes list (folder names) and the editor
/// (folder picker); one database watch for the session.
@Riverpod(keepAlive: true)
Stream<List<Folder>> folders(Ref ref) {
  final userId = ref.watch(
    currentUserIdProvider.select((session) => session.value),
  );
  if (userId == null) return Stream.value(const <Folder>[]);
  return ObserveFolders(ref.watch(folderRepositoryProvider))(const NoParams());
}

/// Folder id -> name, for showing a note's folder.
@riverpod
Map<String, String> folderNames(Ref ref) => {
  for (final folder in ref.watch(foldersProvider).value ?? const <Folder>[])
    folder.id: folder.name,
};

@riverpod
CreateFolder createFolder(Ref ref) => CreateFolder(
  ref.watch(folderRepositoryProvider),
  ref.watch(idGeneratorProvider),
  ref.watch(clockProvider),
);

@riverpod
RenameFolder renameFolder(Ref ref) =>
    RenameFolder(ref.watch(folderRepositoryProvider));

@riverpod
DeleteFolder deleteFolder(Ref ref) =>
    DeleteFolder(ref.watch(folderRepositoryProvider));

/// Number of notes per folder id; the `null` key counts notes in no folder.
/// Computed in one pass over the notes already in memory (no query per
/// folder), so it changes whenever a note is created, moved or deleted, or a
/// folder is deleted.
@riverpod
Map<String?, int> folderNoteCounts(Ref ref) {
  final counts = <String?, int>{};
  for (final note in ref.watch(notesProvider).value ?? const []) {
    counts[note.folderId] = (counts[note.folderId] ?? 0) + 1;
  }
  return counts;
}

/// Create / rename / delete folders from the folders screen. State:
/// `AsyncData(null)` idle or done, `AsyncLoading`, `AsyncError(Failure)`.
@riverpod
class FolderActions extends _$FolderActions {
  @override
  FutureOr<void> build() {}

  Future<Folder?> create(String name) =>
      _run(() => ref.read(createFolderProvider)(name));

  Future<Folder?> rename(Folder folder, String name) =>
      _run(() => ref.read(renameFolderProvider)(folder.copyWith(name: name)));

  Future<bool> delete(String id) async =>
      await _run<bool>(() async {
        await ref.read(deleteFolderProvider)(id);
        return true;
      }) ??
      false;

  Future<T?> _run<T>(Future<T> Function() action) async {
    state = const AsyncLoading();
    T? value;
    final result = await AsyncValue.guard(() async {
      value = await action();
    });
    if (ref.mounted) state = result;
    return result.hasError ? null : value;
  }
}
