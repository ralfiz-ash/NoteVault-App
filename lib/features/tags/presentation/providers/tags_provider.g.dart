// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tags_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The signed-in user's tags (by name), live, including tags no note uses
/// (tags are independent). The single source of every tag's colour. Empty
/// while signed out.
///
/// keepAlive: read by every tag chip (list, note, editor, filters, tag
/// screen); one database watch for the session instead of one per screen.

@ProviderFor(tags)
final tagsProvider = TagsProvider._();

/// The signed-in user's tags (by name), live, including tags no note uses
/// (tags are independent). The single source of every tag's colour. Empty
/// while signed out.
///
/// keepAlive: read by every tag chip (list, note, editor, filters, tag
/// screen); one database watch for the session instead of one per screen.

final class TagsProvider
    extends
        $FunctionalProvider<AsyncValue<List<Tag>>, List<Tag>, Stream<List<Tag>>>
    with $FutureModifier<List<Tag>>, $StreamProvider<List<Tag>> {
  /// The signed-in user's tags (by name), live, including tags no note uses
  /// (tags are independent). The single source of every tag's colour. Empty
  /// while signed out.
  ///
  /// keepAlive: read by every tag chip (list, note, editor, filters, tag
  /// screen); one database watch for the session instead of one per screen.
  TagsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tagsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tagsHash();

  @$internal
  @override
  $StreamProviderElement<List<Tag>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Tag>> create(Ref ref) {
    return tags(ref);
  }
}

String _$tagsHash() => r'19e9a334b6169202b8718dcab39e85a435f16797';

/// Lower-case tag name -> tag, for showing a note's tags (notes store names)
/// with their colour.

@ProviderFor(tagsByName)
final tagsByNameProvider = TagsByNameProvider._();

/// Lower-case tag name -> tag, for showing a note's tags (notes store names)
/// with their colour.

final class TagsByNameProvider
    extends
        $FunctionalProvider<
          Map<String, Tag>,
          Map<String, Tag>,
          Map<String, Tag>
        >
    with $Provider<Map<String, Tag>> {
  /// Lower-case tag name -> tag, for showing a note's tags (notes store names)
  /// with their colour.
  TagsByNameProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tagsByNameProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tagsByNameHash();

  @$internal
  @override
  $ProviderElement<Map<String, Tag>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Map<String, Tag> create(Ref ref) {
    return tagsByName(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, Tag> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, Tag>>(value),
    );
  }
}

String _$tagsByNameHash() => r'7b644322f489ace5a7e60ac2b8250bcbd7865958';

/// Lower-case tag name -> number of notes using it. Derived in one pass from
/// the same notes the list shows (no query per tag, no stored counts).

@ProviderFor(tagNoteCounts)
final tagNoteCountsProvider = TagNoteCountsProvider._();

/// Lower-case tag name -> number of notes using it. Derived in one pass from
/// the same notes the list shows (no query per tag, no stored counts).

final class TagNoteCountsProvider
    extends
        $FunctionalProvider<
          Map<String, int>,
          Map<String, int>,
          Map<String, int>
        >
    with $Provider<Map<String, int>> {
  /// Lower-case tag name -> number of notes using it. Derived in one pass from
  /// the same notes the list shows (no query per tag, no stored counts).
  TagNoteCountsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tagNoteCountsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tagNoteCountsHash();

  @$internal
  @override
  $ProviderElement<Map<String, int>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Map<String, int> create(Ref ref) {
    return tagNoteCounts(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, int> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, int>>(value),
    );
  }
}

String _$tagNoteCountsHash() => r'c07fe67ed0593feceb12c78e5c453c11c8e831cf';

@ProviderFor(createTag)
final createTagProvider = CreateTagProvider._();

final class CreateTagProvider
    extends $FunctionalProvider<CreateTag, CreateTag, CreateTag>
    with $Provider<CreateTag> {
  CreateTagProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createTagProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createTagHash();

  @$internal
  @override
  $ProviderElement<CreateTag> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CreateTag create(Ref ref) {
    return createTag(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreateTag value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreateTag>(value),
    );
  }
}

String _$createTagHash() => r'a37c6220beb58404f58ea33685052b5f476ac567';

@ProviderFor(updateTag)
final updateTagProvider = UpdateTagProvider._();

final class UpdateTagProvider
    extends $FunctionalProvider<UpdateTag, UpdateTag, UpdateTag>
    with $Provider<UpdateTag> {
  UpdateTagProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateTagProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateTagHash();

  @$internal
  @override
  $ProviderElement<UpdateTag> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UpdateTag create(Ref ref) {
    return updateTag(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateTag value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateTag>(value),
    );
  }
}

String _$updateTagHash() => r'f3aa07a5677f4767aab286c8f9e2c953e28117d6';

@ProviderFor(deleteTag)
final deleteTagProvider = DeleteTagProvider._();

final class DeleteTagProvider
    extends $FunctionalProvider<DeleteTag, DeleteTag, DeleteTag>
    with $Provider<DeleteTag> {
  DeleteTagProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deleteTagProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deleteTagHash();

  @$internal
  @override
  $ProviderElement<DeleteTag> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DeleteTag create(Ref ref) {
    return deleteTag(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeleteTag value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeleteTag>(value),
    );
  }
}

String _$deleteTagHash() => r'db0c2664687ad164befa9bed3ccbaa990b7b446b';

/// Create / edit / delete tags from the tags screen. State:
/// `AsyncData(null)` idle or done, `AsyncLoading`, `AsyncError(Failure)`.

@ProviderFor(TagActions)
final tagActionsProvider = TagActionsProvider._();

/// Create / edit / delete tags from the tags screen. State:
/// `AsyncData(null)` idle or done, `AsyncLoading`, `AsyncError(Failure)`.
final class TagActionsProvider
    extends $AsyncNotifierProvider<TagActions, void> {
  /// Create / edit / delete tags from the tags screen. State:
  /// `AsyncData(null)` idle or done, `AsyncLoading`, `AsyncError(Failure)`.
  TagActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tagActionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tagActionsHash();

  @$internal
  @override
  TagActions create() => TagActions();
}

String _$tagActionsHash() => r'ed6e1964f9034e546124e87af0947bb7f0a089fc';

/// Create / edit / delete tags from the tags screen. State:
/// `AsyncData(null)` idle or done, `AsyncLoading`, `AsyncError(Failure)`.

abstract class _$TagActions extends $AsyncNotifier<void> {
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
