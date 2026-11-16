// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notes_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// All notes from the local database (newest edit first), updated live after
/// every change. An empty list is a valid `AsyncData`, not an error.
///
/// keepAlive: this is the shared, local-first cache that `noteProvider`,
/// `folderNotesProvider` and (later) search derive from. Keeping one database
/// watch open avoids re-querying and a loading flash on every navigation.
/// To retry after an error: `ref.invalidate(notesProvider)`.

@ProviderFor(notes)
final notesProvider = NotesProvider._();

/// All notes from the local database (newest edit first), updated live after
/// every change. An empty list is a valid `AsyncData`, not an error.
///
/// keepAlive: this is the shared, local-first cache that `noteProvider`,
/// `folderNotesProvider` and (later) search derive from. Keeping one database
/// watch open avoids re-querying and a loading flash on every navigation.
/// To retry after an error: `ref.invalidate(notesProvider)`.

final class NotesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Note>>,
          List<Note>,
          Stream<List<Note>>
        >
    with $FutureModifier<List<Note>>, $StreamProvider<List<Note>> {
  /// All notes from the local database (newest edit first), updated live after
  /// every change. An empty list is a valid `AsyncData`, not an error.
  ///
  /// keepAlive: this is the shared, local-first cache that `noteProvider`,
  /// `folderNotesProvider` and (later) search derive from. Keeping one database
  /// watch open avoids re-querying and a loading flash on every navigation.
  /// To retry after an error: `ref.invalidate(notesProvider)`.
  NotesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notesHash();

  @$internal
  @override
  $StreamProviderElement<List<Note>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Note>> create(Ref ref) {
    return notes(ref);
  }
}

String _$notesHash() => r'db840fc7ecd09d029324a44827870524a10b4777';
