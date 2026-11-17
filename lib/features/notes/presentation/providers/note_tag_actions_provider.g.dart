// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_tag_actions_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(addTagToNote)
final addTagToNoteProvider = AddTagToNoteProvider._();

final class AddTagToNoteProvider
    extends $FunctionalProvider<AddTagToNote, AddTagToNote, AddTagToNote>
    with $Provider<AddTagToNote> {
  AddTagToNoteProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'addTagToNoteProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$addTagToNoteHash();

  @$internal
  @override
  $ProviderElement<AddTagToNote> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AddTagToNote create(Ref ref) {
    return addTagToNote(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AddTagToNote value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AddTagToNote>(value),
    );
  }
}

String _$addTagToNoteHash() => r'd27933a1921b50106e9c7e48d2b7097fb3cf8c8c';

@ProviderFor(removeTagFromNote)
final removeTagFromNoteProvider = RemoveTagFromNoteProvider._();

final class RemoveTagFromNoteProvider
    extends
        $FunctionalProvider<
          RemoveTagFromNote,
          RemoveTagFromNote,
          RemoveTagFromNote
        >
    with $Provider<RemoveTagFromNote> {
  RemoveTagFromNoteProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'removeTagFromNoteProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$removeTagFromNoteHash();

  @$internal
  @override
  $ProviderElement<RemoveTagFromNote> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RemoveTagFromNote create(Ref ref) {
    return removeTagFromNote(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RemoveTagFromNote value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RemoveTagFromNote>(value),
    );
  }
}

String _$removeTagFromNoteHash() => r'feac3fed87b4615885d72969c70dd75f3f6c366e';

/// Adds/removes a tag on the open note (note screen). Removing only unlinks
/// it; the tag stays available. State: idle/done, loading, or
/// `AsyncError(Failure)`.

@ProviderFor(NoteTagActions)
final noteTagActionsProvider = NoteTagActionsProvider._();

/// Adds/removes a tag on the open note (note screen). Removing only unlinks
/// it; the tag stays available. State: idle/done, loading, or
/// `AsyncError(Failure)`.
final class NoteTagActionsProvider
    extends $AsyncNotifierProvider<NoteTagActions, void> {
  /// Adds/removes a tag on the open note (note screen). Removing only unlinks
  /// it; the tag stays available. State: idle/done, loading, or
  /// `AsyncError(Failure)`.
  NoteTagActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'noteTagActionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$noteTagActionsHash();

  @$internal
  @override
  NoteTagActions create() => NoteTagActions();
}

String _$noteTagActionsHash() => r'748a41d05e5cb9aaefc5dc420928342d53068d7d';

/// Adds/removes a tag on the open note (note screen). Removing only unlinks
/// it; the tag stays available. State: idle/done, loading, or
/// `AsyncError(Failure)`.

abstract class _$NoteTagActions extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
