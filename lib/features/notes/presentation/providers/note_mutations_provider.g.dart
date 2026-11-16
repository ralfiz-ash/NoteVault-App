// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_mutations_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Create / update / delete notes through [NoteRepository].
///
/// State (`AsyncValue<NoteMutationResult?>`):
/// - `AsyncData(null)`: idle, nothing done yet
/// - `AsyncLoading`: a mutation is running
/// - `AsyncData(result)`: the last mutation succeeded
/// - `AsyncError(Failure)`: the last mutation failed
///
/// Call from callbacks with `ref.read(noteMutationsProvider.notifier)`, and
/// keep a `ref.watch` / `ref.listen` on the provider while the screen is open
/// (it is auto-disposed with the screen). The notes list updates by itself
/// because [notesProvider] watches the database.

@ProviderFor(NoteMutations)
final noteMutationsProvider = NoteMutationsProvider._();

/// Create / update / delete notes through [NoteRepository].
///
/// State (`AsyncValue<NoteMutationResult?>`):
/// - `AsyncData(null)`: idle, nothing done yet
/// - `AsyncLoading`: a mutation is running
/// - `AsyncData(result)`: the last mutation succeeded
/// - `AsyncError(Failure)`: the last mutation failed
///
/// Call from callbacks with `ref.read(noteMutationsProvider.notifier)`, and
/// keep a `ref.watch` / `ref.listen` on the provider while the screen is open
/// (it is auto-disposed with the screen). The notes list updates by itself
/// because [notesProvider] watches the database.
final class NoteMutationsProvider
    extends $AsyncNotifierProvider<NoteMutations, NoteMutationResult?> {
  /// Create / update / delete notes through [NoteRepository].
  ///
  /// State (`AsyncValue<NoteMutationResult?>`):
  /// - `AsyncData(null)`: idle, nothing done yet
  /// - `AsyncLoading`: a mutation is running
  /// - `AsyncData(result)`: the last mutation succeeded
  /// - `AsyncError(Failure)`: the last mutation failed
  ///
  /// Call from callbacks with `ref.read(noteMutationsProvider.notifier)`, and
  /// keep a `ref.watch` / `ref.listen` on the provider while the screen is open
  /// (it is auto-disposed with the screen). The notes list updates by itself
  /// because [notesProvider] watches the database.
  NoteMutationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'noteMutationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$noteMutationsHash();

  @$internal
  @override
  NoteMutations create() => NoteMutations();
}

String _$noteMutationsHash() => r'ff752247e73e4b7c0c455b2d831356267a261ed9';

/// Create / update / delete notes through [NoteRepository].
///
/// State (`AsyncValue<NoteMutationResult?>`):
/// - `AsyncData(null)`: idle, nothing done yet
/// - `AsyncLoading`: a mutation is running
/// - `AsyncData(result)`: the last mutation succeeded
/// - `AsyncError(Failure)`: the last mutation failed
///
/// Call from callbacks with `ref.read(noteMutationsProvider.notifier)`, and
/// keep a `ref.watch` / `ref.listen` on the provider while the screen is open
/// (it is auto-disposed with the screen). The notes list updates by itself
/// because [notesProvider] watches the database.

abstract class _$NoteMutations extends $AsyncNotifier<NoteMutationResult?> {
  FutureOr<NoteMutationResult?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<NoteMutationResult?>, NoteMutationResult?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<NoteMutationResult?>, NoteMutationResult?>,
              AsyncValue<NoteMutationResult?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
