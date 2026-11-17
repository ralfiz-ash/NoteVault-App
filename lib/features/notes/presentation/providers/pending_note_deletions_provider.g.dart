// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_note_deletions_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Ids of notes being deleted right now. The list hides them at once
/// (optimistic delete) and shows them again if the delete fails (rollback).
/// Nothing else is copied: the notes themselves stay in [notesProvider].
///
/// keepAlive: a delete started from the note screen continues after that
/// screen closes. Cleared when the user changes.

@ProviderFor(PendingNoteDeletions)
final pendingNoteDeletionsProvider = PendingNoteDeletionsProvider._();

/// Ids of notes being deleted right now. The list hides them at once
/// (optimistic delete) and shows them again if the delete fails (rollback).
/// Nothing else is copied: the notes themselves stay in [notesProvider].
///
/// keepAlive: a delete started from the note screen continues after that
/// screen closes. Cleared when the user changes.
final class PendingNoteDeletionsProvider
    extends $NotifierProvider<PendingNoteDeletions, Set<String>> {
  /// Ids of notes being deleted right now. The list hides them at once
  /// (optimistic delete) and shows them again if the delete fails (rollback).
  /// Nothing else is copied: the notes themselves stay in [notesProvider].
  ///
  /// keepAlive: a delete started from the note screen continues after that
  /// screen closes. Cleared when the user changes.
  PendingNoteDeletionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingNoteDeletionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingNoteDeletionsHash();

  @$internal
  @override
  PendingNoteDeletions create() => PendingNoteDeletions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }
}

String _$pendingNoteDeletionsHash() =>
    r'9951afa3549ead919cd97e11ae0b760537c591be';

/// Ids of notes being deleted right now. The list hides them at once
/// (optimistic delete) and shows them again if the delete fails (rollback).
/// Nothing else is copied: the notes themselves stay in [notesProvider].
///
/// keepAlive: a delete started from the note screen continues after that
/// screen closes. Cleared when the user changes.

abstract class _$PendingNoteDeletions extends $Notifier<Set<String>> {
  Set<String> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Set<String>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<String>, Set<String>>,
              Set<String>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
