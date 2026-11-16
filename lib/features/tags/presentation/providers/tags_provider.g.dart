// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tags_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The signed-in user's tags (by name), live, including tags no note uses
/// any more (tags are independent). Used for tag suggestions. Empty while
/// signed out.

@ProviderFor(tags)
final tagsProvider = TagsProvider._();

/// The signed-in user's tags (by name), live, including tags no note uses
/// any more (tags are independent). Used for tag suggestions. Empty while
/// signed out.

final class TagsProvider
    extends
        $FunctionalProvider<AsyncValue<List<Tag>>, List<Tag>, Stream<List<Tag>>>
    with $FutureModifier<List<Tag>>, $StreamProvider<List<Tag>> {
  /// The signed-in user's tags (by name), live, including tags no note uses
  /// any more (tags are independent). Used for tag suggestions. Empty while
  /// signed out.
  TagsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tagsProvider',
        isAutoDispose: true,
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

String _$tagsHash() => r'c8189fb3d127744ed3b932af04f2ae3265e6e2af';
