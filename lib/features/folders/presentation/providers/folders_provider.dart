import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../app/di/database_providers.dart';
import '../../../../app/di/repository_providers.dart';
import '../../../../app/di/session_providers.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/folder.dart';
import '../../domain/usecases/create_folder.dart';
import '../../domain/usecases/observe_folders.dart';

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
