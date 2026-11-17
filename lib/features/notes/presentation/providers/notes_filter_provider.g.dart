// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notes_filter_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// How long typing must pause before the search is applied.

@ProviderFor(searchDebounce)
final searchDebounceProvider = SearchDebounceProvider._();

/// How long typing must pause before the search is applied.

final class SearchDebounceProvider
    extends $FunctionalProvider<Duration, Duration, Duration>
    with $Provider<Duration> {
  /// How long typing must pause before the search is applied.
  SearchDebounceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchDebounceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchDebounceHash();

  @$internal
  @override
  $ProviderElement<Duration> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Duration create(Ref ref) {
    return searchDebounce(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Duration value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Duration>(value),
    );
  }
}

String _$searchDebounceHash() => r'd56b0b51004647967bceed216abab75aae214e96';

/// The applied (debounced, trimmed) search text.
///
/// [onInput] is called for every keystroke; it restarts a timer and only the
/// last value is applied once typing pauses, so the list is not refiltered
/// per character. The timer is cancelled when the provider is disposed or
/// rebuilt (user change). State only changes when the text really changes.

@ProviderFor(NoteSearchController)
final noteSearchControllerProvider = NoteSearchControllerProvider._();

/// The applied (debounced, trimmed) search text.
///
/// [onInput] is called for every keystroke; it restarts a timer and only the
/// last value is applied once typing pauses, so the list is not refiltered
/// per character. The timer is cancelled when the provider is disposed or
/// rebuilt (user change). State only changes when the text really changes.
final class NoteSearchControllerProvider
    extends $NotifierProvider<NoteSearchController, String> {
  /// The applied (debounced, trimmed) search text.
  ///
  /// [onInput] is called for every keystroke; it restarts a timer and only the
  /// last value is applied once typing pauses, so the list is not refiltered
  /// per character. The timer is cancelled when the provider is disposed or
  /// rebuilt (user change). State only changes when the text really changes.
  NoteSearchControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'noteSearchControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$noteSearchControllerHash();

  @$internal
  @override
  NoteSearchController create() => NoteSearchController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$noteSearchControllerHash() =>
    r'b1bfaa25559708a30598689e24310f00e6ea540a';

/// The applied (debounced, trimmed) search text.
///
/// [onInput] is called for every keystroke; it restarts a timer and only the
/// last value is applied once typing pauses, so the list is not refiltered
/// per character. The timer is cancelled when the provider is disposed or
/// rebuilt (user change). State only changes when the text really changes.

abstract class _$NoteSearchController extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Folder and tag selection of the notes list. Resets when the user changes.

@ProviderFor(NotesFilterController)
final notesFilterControllerProvider = NotesFilterControllerProvider._();

/// Folder and tag selection of the notes list. Resets when the user changes.
final class NotesFilterControllerProvider
    extends $NotifierProvider<NotesFilterController, NotesFilterState> {
  /// Folder and tag selection of the notes list. Resets when the user changes.
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
  Override overrideWithValue(NotesFilterState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotesFilterState>(value),
    );
  }
}

String _$notesFilterControllerHash() =>
    r'6dfbaa873305f58bc753508798c680e9c6a3cb44';

/// Folder and tag selection of the notes list. Resets when the user changes.

abstract class _$NotesFilterController extends $Notifier<NotesFilterState> {
  NotesFilterState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<NotesFilterState, NotesFilterState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<NotesFilterState, NotesFilterState>,
              NotesFilterState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The full query (search + folder + tag + sort) built from its sources.
/// Only the pieces it uses are watched (e.g. the sort, not the theme; the
/// selected tag's name, not every tag colour), so unrelated changes do not
/// recompute the list.

@ProviderFor(noteQuery)
final noteQueryProvider = NoteQueryProvider._();

/// The full query (search + folder + tag + sort) built from its sources.
/// Only the pieces it uses are watched (e.g. the sort, not the theme; the
/// selected tag's name, not every tag colour), so unrelated changes do not
/// recompute the list.

final class NoteQueryProvider
    extends $FunctionalProvider<NoteQuery, NoteQuery, NoteQuery>
    with $Provider<NoteQuery> {
  /// The full query (search + folder + tag + sort) built from its sources.
  /// Only the pieces it uses are watched (e.g. the sort, not the theme; the
  /// selected tag's name, not every tag colour), so unrelated changes do not
  /// recompute the list.
  NoteQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'noteQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$noteQueryHash();

  @$internal
  @override
  $ProviderElement<NoteQuery> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  NoteQuery create(Ref ref) {
    return noteQuery(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NoteQuery value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NoteQuery>(value),
    );
  }
}

String _$noteQueryHash() => r'52862b024c4f28ffce642d857f6c706531a142d1';

/// THE list the notes screen shows: the user's notes (minus deletions in
/// progress) filtered and sorted by [noteQueryProvider] in one pass. Derived
/// only; nothing is stored. Loading and errors of the notes pass through
/// unchanged (an error is never turned into an empty list).

@ProviderFor(filteredNotes)
final filteredNotesProvider = FilteredNotesProvider._();

/// THE list the notes screen shows: the user's notes (minus deletions in
/// progress) filtered and sorted by [noteQueryProvider] in one pass. Derived
/// only; nothing is stored. Loading and errors of the notes pass through
/// unchanged (an error is never turned into an empty list).

final class FilteredNotesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Note>>,
          AsyncValue<List<Note>>,
          AsyncValue<List<Note>>
        >
    with $Provider<AsyncValue<List<Note>>> {
  /// THE list the notes screen shows: the user's notes (minus deletions in
  /// progress) filtered and sorted by [noteQueryProvider] in one pass. Derived
  /// only; nothing is stored. Loading and errors of the notes pass through
  /// unchanged (an error is never turned into an empty list).
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

String _$filteredNotesHash() => r'b5d9d687fdc5b842325cf3f6fbd9b1dfb193c4d7';
