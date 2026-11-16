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
