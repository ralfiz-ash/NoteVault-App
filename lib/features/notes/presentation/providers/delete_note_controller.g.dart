// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_note_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Deletes notes optimistically.
///
/// 1. The note is hidden from the list immediately ([PendingNoteDeletions]).
/// 2. The delete runs.
/// 3. Success: the database no longer has it, so it stays gone.
///    Failure: it is shown again (rollback) and the state becomes
///    `AsyncError(Failure)` so the list can say "Unable to delete note".
///
/// The notes list listens to this provider, so a delete started from the
/// note screen keeps running (and reports errors) after that screen closes.

@ProviderFor(DeleteNoteController)
final deleteNoteControllerProvider = DeleteNoteControllerProvider._();

/// Deletes notes optimistically.
///
/// 1. The note is hidden from the list immediately ([PendingNoteDeletions]).
/// 2. The delete runs.
/// 3. Success: the database no longer has it, so it stays gone.
///    Failure: it is shown again (rollback) and the state becomes
///    `AsyncError(Failure)` so the list can say "Unable to delete note".
///
/// The notes list listens to this provider, so a delete started from the
/// note screen keeps running (and reports errors) after that screen closes.
final class DeleteNoteControllerProvider
    extends $AsyncNotifierProvider<DeleteNoteController, String?> {
  /// Deletes notes optimistically.
  ///
  /// 1. The note is hidden from the list immediately ([PendingNoteDeletions]).
  /// 2. The delete runs.
  /// 3. Success: the database no longer has it, so it stays gone.
  ///    Failure: it is shown again (rollback) and the state becomes
  ///    `AsyncError(Failure)` so the list can say "Unable to delete note".
  ///
  /// The notes list listens to this provider, so a delete started from the
  /// note screen keeps running (and reports errors) after that screen closes.
  DeleteNoteControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deleteNoteControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deleteNoteControllerHash();

  @$internal
  @override
  DeleteNoteController create() => DeleteNoteController();
}

String _$deleteNoteControllerHash() =>
    r'720465e9f4d8e1ff6ad109f564c0c981d5c2dee9';

/// Deletes notes optimistically.
///
/// 1. The note is hidden from the list immediately ([PendingNoteDeletions]).
/// 2. The delete runs.
/// 3. Success: the database no longer has it, so it stays gone.
///    Failure: it is shown again (rollback) and the state becomes
///    `AsyncError(Failure)` so the list can say "Unable to delete note".
///
/// The notes list listens to this provider, so a delete started from the
/// note screen keeps running (and reports errors) after that screen closes.

abstract class _$DeleteNoteController extends $AsyncNotifier<String?> {
  FutureOr<String?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<String?>, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<String?>, String?>,
              AsyncValue<String?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
