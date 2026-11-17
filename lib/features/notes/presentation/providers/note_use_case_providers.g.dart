// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_use_case_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Note use cases on top of the injected [NoteRepository] (the signed-in
/// user's local database). Stateless, so auto-disposed when unused.
/// keepAlive because the long-lived `notesProvider` depends on it.

@ProviderFor(observeNotes)
final observeNotesProvider = ObserveNotesProvider._();

/// Note use cases on top of the injected [NoteRepository] (the signed-in
/// user's local database). Stateless, so auto-disposed when unused.
/// keepAlive because the long-lived `notesProvider` depends on it.

final class ObserveNotesProvider
    extends $FunctionalProvider<ObserveNotes, ObserveNotes, ObserveNotes>
    with $Provider<ObserveNotes> {
  /// Note use cases on top of the injected [NoteRepository] (the signed-in
  /// user's local database). Stateless, so auto-disposed when unused.
  /// keepAlive because the long-lived `notesProvider` depends on it.
  ObserveNotesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'observeNotesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$observeNotesHash();

  @$internal
  @override
  $ProviderElement<ObserveNotes> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ObserveNotes create(Ref ref) {
    return observeNotes(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ObserveNotes value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ObserveNotes>(value),
    );
  }
}

String _$observeNotesHash() => r'787ff003761c32cab4f3d370c4e6f0cab8b5b708';

@ProviderFor(createNote)
final createNoteProvider = CreateNoteProvider._();

final class CreateNoteProvider
    extends $FunctionalProvider<CreateNote, CreateNote, CreateNote>
    with $Provider<CreateNote> {
  CreateNoteProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createNoteProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createNoteHash();

  @$internal
  @override
  $ProviderElement<CreateNote> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CreateNote create(Ref ref) {
    return createNote(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreateNote value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreateNote>(value),
    );
  }
}

String _$createNoteHash() => r'c226e646c44c043c58ad41bd80e7ac5216f3cb99';

@ProviderFor(updateNote)
final updateNoteProvider = UpdateNoteProvider._();

final class UpdateNoteProvider
    extends $FunctionalProvider<UpdateNote, UpdateNote, UpdateNote>
    with $Provider<UpdateNote> {
  UpdateNoteProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateNoteProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateNoteHash();

  @$internal
  @override
  $ProviderElement<UpdateNote> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UpdateNote create(Ref ref) {
    return updateNote(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateNote value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateNote>(value),
    );
  }
}

String _$updateNoteHash() => r'0894648c2b565501199a617215951d2edc0c7d35';

@ProviderFor(deleteNote)
final deleteNoteProvider = DeleteNoteProvider._();

final class DeleteNoteProvider
    extends $FunctionalProvider<DeleteNote, DeleteNote, DeleteNote>
    with $Provider<DeleteNote> {
  DeleteNoteProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deleteNoteProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deleteNoteHash();

  @$internal
  @override
  $ProviderElement<DeleteNote> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DeleteNote create(Ref ref) {
    return deleteNote(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeleteNote value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeleteNote>(value),
    );
  }
}

String _$deleteNoteHash() => r'117cb8bb696d514abd41df8da47263d67b04d06d';
