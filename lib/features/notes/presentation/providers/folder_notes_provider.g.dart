// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'folder_notes_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notes in one folder, in the same order as [notesProvider].
///
/// Derived (filtered) from [notesProvider], so it reacts to every change
/// without duplicating note data. One cached instance per folder id,
/// auto-disposed when no longer used.

@ProviderFor(folderNotes)
final folderNotesProvider = FolderNotesFamily._();

/// Notes in one folder, in the same order as [notesProvider].
///
/// Derived (filtered) from [notesProvider], so it reacts to every change
/// without duplicating note data. One cached instance per folder id,
/// auto-disposed when no longer used.

final class FolderNotesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Note>>,
          List<Note>,
          FutureOr<List<Note>>
        >
    with $FutureModifier<List<Note>>, $FutureProvider<List<Note>> {
  /// Notes in one folder, in the same order as [notesProvider].
  ///
  /// Derived (filtered) from [notesProvider], so it reacts to every change
  /// without duplicating note data. One cached instance per folder id,
  /// auto-disposed when no longer used.
  FolderNotesProvider._({
    required FolderNotesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'folderNotesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$folderNotesHash();

  @override
  String toString() {
    return r'folderNotesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Note>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Note>> create(Ref ref) {
    final argument = this.argument as String;
    return folderNotes(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FolderNotesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$folderNotesHash() => r'3d614159130bfd8e4e9e4f58ef48c84a811dba1f';

/// Notes in one folder, in the same order as [notesProvider].
///
/// Derived (filtered) from [notesProvider], so it reacts to every change
/// without duplicating note data. One cached instance per folder id,
/// auto-disposed when no longer used.

final class FolderNotesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Note>>, String> {
  FolderNotesFamily._()
    : super(
        retry: null,
        name: r'folderNotesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Notes in one folder, in the same order as [notesProvider].
  ///
  /// Derived (filtered) from [notesProvider], so it reacts to every change
  /// without duplicating note data. One cached instance per folder id,
  /// auto-disposed when no longer used.

  FolderNotesProvider call(String folderId) =>
      FolderNotesProvider._(argument: folderId, from: this);

  @override
  String toString() => r'folderNotesProvider';
}
