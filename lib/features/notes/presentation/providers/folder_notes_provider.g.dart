// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'folder_notes_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notes in one folder ([folderId] == null: notes in no folder), in list
/// order. Filtered from [visibleNotesProvider] (no extra query, and notes
/// being deleted are already hidden), so it updates on every change. One
/// instance per folder id, auto-disposed when unused.

@ProviderFor(folderNotes)
final folderNotesProvider = FolderNotesFamily._();

/// Notes in one folder ([folderId] == null: notes in no folder), in list
/// order. Filtered from [visibleNotesProvider] (no extra query, and notes
/// being deleted are already hidden), so it updates on every change. One
/// instance per folder id, auto-disposed when unused.

final class FolderNotesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Note>>,
          AsyncValue<List<Note>>,
          AsyncValue<List<Note>>
        >
    with $Provider<AsyncValue<List<Note>>> {
  /// Notes in one folder ([folderId] == null: notes in no folder), in list
  /// order. Filtered from [visibleNotesProvider] (no extra query, and notes
  /// being deleted are already hidden), so it updates on every change. One
  /// instance per folder id, auto-disposed when unused.
  FolderNotesProvider._({
    required FolderNotesFamily super.from,
    required String? super.argument,
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
  $ProviderElement<AsyncValue<List<Note>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<List<Note>> create(Ref ref) {
    final argument = this.argument as String?;
    return folderNotes(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<Note>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<Note>>>(value),
    );
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

String _$folderNotesHash() => r'8e5be6992668fbd6633d73267f2c8f8407d26eba';

/// Notes in one folder ([folderId] == null: notes in no folder), in list
/// order. Filtered from [visibleNotesProvider] (no extra query, and notes
/// being deleted are already hidden), so it updates on every change. One
/// instance per folder id, auto-disposed when unused.

final class FolderNotesFamily extends $Family
    with $FunctionalFamilyOverride<AsyncValue<List<Note>>, String?> {
  FolderNotesFamily._()
    : super(
        retry: null,
        name: r'folderNotesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Notes in one folder ([folderId] == null: notes in no folder), in list
  /// order. Filtered from [visibleNotesProvider] (no extra query, and notes
  /// being deleted are already hidden), so it updates on every change. One
  /// instance per folder id, auto-disposed when unused.

  FolderNotesProvider call(String? folderId) =>
      FolderNotesProvider._(argument: folderId, from: this);

  @override
  String toString() => r'folderNotesProvider';
}
