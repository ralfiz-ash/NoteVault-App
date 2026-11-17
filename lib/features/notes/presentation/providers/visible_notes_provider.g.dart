// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visible_notes_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// What the notes list shows: [notesProvider] minus notes whose deletion is
/// in progress. Keeps the loading / error / data state of [notesProvider].

@ProviderFor(visibleNotes)
final visibleNotesProvider = VisibleNotesProvider._();

/// What the notes list shows: [notesProvider] minus notes whose deletion is
/// in progress. Keeps the loading / error / data state of [notesProvider].

final class VisibleNotesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Note>>,
          AsyncValue<List<Note>>,
          AsyncValue<List<Note>>
        >
    with $Provider<AsyncValue<List<Note>>> {
  /// What the notes list shows: [notesProvider] minus notes whose deletion is
  /// in progress. Keeps the loading / error / data state of [notesProvider].
  VisibleNotesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'visibleNotesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$visibleNotesHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<List<Note>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<List<Note>> create(Ref ref) {
    return visibleNotes(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<Note>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<Note>>>(value),
    );
  }
}

String _$visibleNotesHash() => r'cfcc1c8f64fdde2248da437ae8be323f5e04fa9c';
