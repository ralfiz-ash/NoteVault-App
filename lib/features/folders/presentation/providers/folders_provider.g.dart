// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'folders_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The signed-in user's folders (by name), live. Empty while signed out, for
/// the same isolation reason as `notesProvider`.
///
/// keepAlive: shared by the notes list (folder names) and the editor
/// (folder picker); one database watch for the session.

@ProviderFor(folders)
final foldersProvider = FoldersProvider._();

/// The signed-in user's folders (by name), live. Empty while signed out, for
/// the same isolation reason as `notesProvider`.
///
/// keepAlive: shared by the notes list (folder names) and the editor
/// (folder picker); one database watch for the session.

final class FoldersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Folder>>,
          List<Folder>,
          Stream<List<Folder>>
        >
    with $FutureModifier<List<Folder>>, $StreamProvider<List<Folder>> {
  /// The signed-in user's folders (by name), live. Empty while signed out, for
  /// the same isolation reason as `notesProvider`.
  ///
  /// keepAlive: shared by the notes list (folder names) and the editor
  /// (folder picker); one database watch for the session.
  FoldersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'foldersProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$foldersHash();

  @$internal
  @override
  $StreamProviderElement<List<Folder>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Folder>> create(Ref ref) {
    return folders(ref);
  }
}

String _$foldersHash() => r'9e4cc3ea92f26710e50d2e7fc002869024456548';

/// Folder id -> name, for showing a note's folder.

@ProviderFor(folderNames)
final folderNamesProvider = FolderNamesProvider._();

/// Folder id -> name, for showing a note's folder.

final class FolderNamesProvider
    extends
        $FunctionalProvider<
          Map<String, String>,
          Map<String, String>,
          Map<String, String>
        >
    with $Provider<Map<String, String>> {
  /// Folder id -> name, for showing a note's folder.
  FolderNamesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'folderNamesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$folderNamesHash();

  @$internal
  @override
  $ProviderElement<Map<String, String>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Map<String, String> create(Ref ref) {
    return folderNames(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, String>>(value),
    );
  }
}

String _$folderNamesHash() => r'c0b3c3adf8ee03464998cbe548034a748fb6fcfc';

@ProviderFor(createFolder)
final createFolderProvider = CreateFolderProvider._();

final class CreateFolderProvider
    extends $FunctionalProvider<CreateFolder, CreateFolder, CreateFolder>
    with $Provider<CreateFolder> {
  CreateFolderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createFolderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createFolderHash();

  @$internal
  @override
  $ProviderElement<CreateFolder> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CreateFolder create(Ref ref) {
    return createFolder(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreateFolder value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreateFolder>(value),
    );
  }
}

String _$createFolderHash() => r'12e108753b92d74c4ee70a4ff1264209f64b94b4';

@ProviderFor(renameFolder)
final renameFolderProvider = RenameFolderProvider._();

final class RenameFolderProvider
    extends $FunctionalProvider<RenameFolder, RenameFolder, RenameFolder>
    with $Provider<RenameFolder> {
  RenameFolderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'renameFolderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$renameFolderHash();

  @$internal
  @override
  $ProviderElement<RenameFolder> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RenameFolder create(Ref ref) {
    return renameFolder(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RenameFolder value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RenameFolder>(value),
    );
  }
}

String _$renameFolderHash() => r'a795de132933a78ce50fbe7008b05fa442b523a0';

@ProviderFor(deleteFolder)
final deleteFolderProvider = DeleteFolderProvider._();

final class DeleteFolderProvider
    extends $FunctionalProvider<DeleteFolder, DeleteFolder, DeleteFolder>
    with $Provider<DeleteFolder> {
  DeleteFolderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deleteFolderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deleteFolderHash();

  @$internal
  @override
  $ProviderElement<DeleteFolder> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DeleteFolder create(Ref ref) {
    return deleteFolder(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeleteFolder value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeleteFolder>(value),
    );
  }
}

String _$deleteFolderHash() => r'd2115f036f5d1e3551a5f8cb6dd257955dcb7b21';

/// Number of notes per folder id; the `null` key counts notes in no folder.
/// Computed in one pass over the notes already in memory (no query per
/// folder), so it changes whenever a note is created, moved or deleted, or a
/// folder is deleted.

@ProviderFor(folderNoteCounts)
final folderNoteCountsProvider = FolderNoteCountsProvider._();

/// Number of notes per folder id; the `null` key counts notes in no folder.
/// Computed in one pass over the notes already in memory (no query per
/// folder), so it changes whenever a note is created, moved or deleted, or a
/// folder is deleted.

final class FolderNoteCountsProvider
    extends
        $FunctionalProvider<
          Map<String?, int>,
          Map<String?, int>,
          Map<String?, int>
        >
    with $Provider<Map<String?, int>> {
  /// Number of notes per folder id; the `null` key counts notes in no folder.
  /// Computed in one pass over the notes already in memory (no query per
  /// folder), so it changes whenever a note is created, moved or deleted, or a
  /// folder is deleted.
  FolderNoteCountsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'folderNoteCountsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$folderNoteCountsHash();

  @$internal
  @override
  $ProviderElement<Map<String?, int>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Map<String?, int> create(Ref ref) {
    return folderNoteCounts(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String?, int> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String?, int>>(value),
    );
  }
}

String _$folderNoteCountsHash() => r'9da44bb575ea2d867183642327e3409082dcca29';

/// Create / rename / delete folders from the folders screen. State:
/// `AsyncData(null)` idle or done, `AsyncLoading`, `AsyncError(Failure)`.

@ProviderFor(FolderActions)
final folderActionsProvider = FolderActionsProvider._();

/// Create / rename / delete folders from the folders screen. State:
/// `AsyncData(null)` idle or done, `AsyncLoading`, `AsyncError(Failure)`.
final class FolderActionsProvider
    extends $AsyncNotifierProvider<FolderActions, void> {
  /// Create / rename / delete folders from the folders screen. State:
  /// `AsyncData(null)` idle or done, `AsyncLoading`, `AsyncError(Failure)`.
  FolderActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'folderActionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$folderActionsHash();

  @$internal
  @override
  FolderActions create() => FolderActions();
}

String _$folderActionsHash() => r'ca94c1b18b19345202c55635590e3b85fb97c3ea';

/// Create / rename / delete folders from the folders screen. State:
/// `AsyncData(null)` idle or done, `AsyncLoading`, `AsyncError(Failure)`.

abstract class _$FolderActions extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
