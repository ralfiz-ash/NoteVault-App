// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_note_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Creates a note for the "new note" editor.
///
/// State: `AsyncData(null)` idle, `AsyncLoading` saving, `AsyncData(note)`
/// created, `AsyncError(Failure)` failed. Not optimistic: the local database
/// answers in milliseconds and the list updates from it by itself, so there
/// is no temporary note that could be shown and then turn out not to exist.

@ProviderFor(CreateNoteController)
final createNoteControllerProvider = CreateNoteControllerProvider._();

/// Creates a note for the "new note" editor.
///
/// State: `AsyncData(null)` idle, `AsyncLoading` saving, `AsyncData(note)`
/// created, `AsyncError(Failure)` failed. Not optimistic: the local database
/// answers in milliseconds and the list updates from it by itself, so there
/// is no temporary note that could be shown and then turn out not to exist.
final class CreateNoteControllerProvider
    extends $AsyncNotifierProvider<CreateNoteController, Note?> {
  /// Creates a note for the "new note" editor.
  ///
  /// State: `AsyncData(null)` idle, `AsyncLoading` saving, `AsyncData(note)`
  /// created, `AsyncError(Failure)` failed. Not optimistic: the local database
  /// answers in milliseconds and the list updates from it by itself, so there
  /// is no temporary note that could be shown and then turn out not to exist.
  CreateNoteControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createNoteControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createNoteControllerHash();

  @$internal
  @override
  CreateNoteController create() => CreateNoteController();
}

String _$createNoteControllerHash() =>
    r'36c39679f7e153be18893f7b98db85594b8d64b5';

/// Creates a note for the "new note" editor.
///
/// State: `AsyncData(null)` idle, `AsyncLoading` saving, `AsyncData(note)`
/// created, `AsyncError(Failure)` failed. Not optimistic: the local database
/// answers in milliseconds and the list updates from it by itself, so there
/// is no temporary note that could be shown and then turn out not to exist.

abstract class _$CreateNoteController extends $AsyncNotifier<Note?> {
  FutureOr<Note?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Note?>, Note?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Note?>, Note?>,
              AsyncValue<Note?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
