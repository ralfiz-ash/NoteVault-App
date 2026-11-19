// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_note_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Saves edits for the "edit note" editor.
///
/// State: `AsyncData(null)` idle, `AsyncLoading` saving, `AsyncData(note)`
/// saved, `AsyncError(Failure)` failed. Not optimistic (same reason as
/// creating): the list and `noteProvider(id)` update from the database as
/// soon as the save is stored, and a failure leaves them untouched.

@ProviderFor(UpdateNoteController)
final updateNoteControllerProvider = UpdateNoteControllerProvider._();

/// Saves edits for the "edit note" editor.
///
/// State: `AsyncData(null)` idle, `AsyncLoading` saving, `AsyncData(note)`
/// saved, `AsyncError(Failure)` failed. Not optimistic (same reason as
/// creating): the list and `noteProvider(id)` update from the database as
/// soon as the save is stored, and a failure leaves them untouched.
final class UpdateNoteControllerProvider
    extends $AsyncNotifierProvider<UpdateNoteController, Note?> {
  /// Saves edits for the "edit note" editor.
  ///
  /// State: `AsyncData(null)` idle, `AsyncLoading` saving, `AsyncData(note)`
  /// saved, `AsyncError(Failure)` failed. Not optimistic (same reason as
  /// creating): the list and `noteProvider(id)` update from the database as
  /// soon as the save is stored, and a failure leaves them untouched.
  UpdateNoteControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateNoteControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateNoteControllerHash();

  @$internal
  @override
  UpdateNoteController create() => UpdateNoteController();
}

String _$updateNoteControllerHash() =>
    r'ee7427d60b83c80f08fcaa8485546c0342a5737f';

/// Saves edits for the "edit note" editor.
///
/// State: `AsyncData(null)` idle, `AsyncLoading` saving, `AsyncData(note)`
/// saved, `AsyncError(Failure)` failed. Not optimistic (same reason as
/// creating): the list and `noteProvider(id)` update from the database as
/// soon as the save is stored, and a failure leaves them untouched.

abstract class _$UpdateNoteController extends $AsyncNotifier<Note?> {
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
