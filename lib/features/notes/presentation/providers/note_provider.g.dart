// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// One note by id, e.g. for the editor: `ref.watch(noteProvider(id))`.
///
/// Derived from [notesProvider], so it updates when the note changes and
/// does not run its own query. Each id gets its own cached instance, and it
/// is auto-disposed when no screen uses that id any more.
///
/// Errors with `NotFoundFailure` if the note does not exist (or was deleted).

@ProviderFor(note)
final noteProvider = NoteFamily._();

/// One note by id, e.g. for the editor: `ref.watch(noteProvider(id))`.
///
/// Derived from [notesProvider], so it updates when the note changes and
/// does not run its own query. Each id gets its own cached instance, and it
/// is auto-disposed when no screen uses that id any more.
///
/// Errors with `NotFoundFailure` if the note does not exist (or was deleted).

final class NoteProvider
    extends $FunctionalProvider<AsyncValue<Note>, Note, FutureOr<Note>>
    with $FutureModifier<Note>, $FutureProvider<Note> {
  /// One note by id, e.g. for the editor: `ref.watch(noteProvider(id))`.
  ///
  /// Derived from [notesProvider], so it updates when the note changes and
  /// does not run its own query. Each id gets its own cached instance, and it
  /// is auto-disposed when no screen uses that id any more.
  ///
  /// Errors with `NotFoundFailure` if the note does not exist (or was deleted).
  NoteProvider._({
    required NoteFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'noteProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$noteHash();

  @override
  String toString() {
    return r'noteProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Note> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Note> create(Ref ref) {
    final argument = this.argument as String;
    return note(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is NoteProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$noteHash() => r'7b1a1884e6312e8155622406370a150d168c819b';

/// One note by id, e.g. for the editor: `ref.watch(noteProvider(id))`.
///
/// Derived from [notesProvider], so it updates when the note changes and
/// does not run its own query. Each id gets its own cached instance, and it
/// is auto-disposed when no screen uses that id any more.
///
/// Errors with `NotFoundFailure` if the note does not exist (or was deleted).

final class NoteFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Note>, String> {
  NoteFamily._()
    : super(
        retry: null,
        name: r'noteProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One note by id, e.g. for the editor: `ref.watch(noteProvider(id))`.
  ///
  /// Derived from [notesProvider], so it updates when the note changes and
  /// does not run its own query. Each id gets its own cached instance, and it
  /// is auto-disposed when no screen uses that id any more.
  ///
  /// Errors with `NotFoundFailure` if the note does not exist (or was deleted).

  NoteProvider call(String id) => NoteProvider._(argument: id, from: this);

  @override
  String toString() => r'noteProvider';
}
