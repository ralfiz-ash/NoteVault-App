// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notes_filter_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The list's current filter (all / folder / no folder / tag). Screen state
/// of the notes list, so it is auto-disposed with it; it resets when the
/// user changes.

@ProviderFor(NotesFilterController)
final notesFilterControllerProvider = NotesFilterControllerProvider._();

/// The list's current filter (all / folder / no folder / tag). Screen state
/// of the notes list, so it is auto-disposed with it; it resets when the
/// user changes.
final class NotesFilterControllerProvider
    extends $NotifierProvider<NotesFilterController, NotesFilter> {
  /// The list's current filter (all / folder / no folder / tag). Screen state
  /// of the notes list, so it is auto-disposed with it; it resets when the
  /// user changes.
  NotesFilterControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notesFilterControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notesFilterControllerHash();

  @$internal
  @override
  NotesFilterController create() => NotesFilterController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotesFilter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotesFilter>(value),
    );
  }
}

String _$notesFilterControllerHash() =>
    r'b9f1cef3347cdb66eac5a6b385c9059d83aef0ae';

/// The list's current filter (all / folder / no folder / tag). Screen state
/// of the notes list, so it is auto-disposed with it; it resets when the
/// user changes.

abstract class _$NotesFilterController extends $Notifier<NotesFilter> {
  NotesFilter build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<NotesFilter, NotesFilter>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<NotesFilter, NotesFilter>,
              NotesFilter,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The notes the list shows for the current filter. Delegates to the
/// per-folder / per-tag family providers, so each filter is its own cached,
/// independent instance.

@ProviderFor(filteredNotes)
final filteredNotesProvider = FilteredNotesProvider._();

/// The notes the list shows for the current filter. Delegates to the
/// per-folder / per-tag family providers, so each filter is its own cached,
/// independent instance.

final class FilteredNotesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Note>>,
          AsyncValue<List<Note>>,
          AsyncValue<List<Note>>
        >
    with $Provider<AsyncValue<List<Note>>> {
  /// The notes the list shows for the current filter. Delegates to the
  /// per-folder / per-tag family providers, so each filter is its own cached,
  /// independent instance.
  FilteredNotesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredNotesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredNotesHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<List<Note>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<List<Note>> create(Ref ref) {
    return filteredNotes(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<Note>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<Note>>>(value),
    );
  }
}

String _$filteredNotesHash() => r'065f0d9bca891fcc793dbcdbdbd38e878643030b';
