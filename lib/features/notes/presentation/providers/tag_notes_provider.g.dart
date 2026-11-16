// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag_notes_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notes that use the tag [tagId], in list order. Derived from
/// [visibleNotesProvider] and [tagsProvider] (notes store tag names; tags
/// map ids to names, matched ignoring case), so renaming a tag keeps the
/// filter working. One instance per tag id, auto-disposed when unused.

@ProviderFor(tagNotes)
final tagNotesProvider = TagNotesFamily._();

/// Notes that use the tag [tagId], in list order. Derived from
/// [visibleNotesProvider] and [tagsProvider] (notes store tag names; tags
/// map ids to names, matched ignoring case), so renaming a tag keeps the
/// filter working. One instance per tag id, auto-disposed when unused.

final class TagNotesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Note>>,
          AsyncValue<List<Note>>,
          AsyncValue<List<Note>>
        >
    with $Provider<AsyncValue<List<Note>>> {
  /// Notes that use the tag [tagId], in list order. Derived from
  /// [visibleNotesProvider] and [tagsProvider] (notes store tag names; tags
  /// map ids to names, matched ignoring case), so renaming a tag keeps the
  /// filter working. One instance per tag id, auto-disposed when unused.
  TagNotesProvider._({
    required TagNotesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'tagNotesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tagNotesHash();

  @override
  String toString() {
    return r'tagNotesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<AsyncValue<List<Note>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<List<Note>> create(Ref ref) {
    final argument = this.argument as String;
    return tagNotes(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<Note>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<Note>>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TagNotesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tagNotesHash() => r'7ec6e79deaa6764e7141c338ac4c099a8608a528';

/// Notes that use the tag [tagId], in list order. Derived from
/// [visibleNotesProvider] and [tagsProvider] (notes store tag names; tags
/// map ids to names, matched ignoring case), so renaming a tag keeps the
/// filter working. One instance per tag id, auto-disposed when unused.

final class TagNotesFamily extends $Family
    with $FunctionalFamilyOverride<AsyncValue<List<Note>>, String> {
  TagNotesFamily._()
    : super(
        retry: null,
        name: r'tagNotesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Notes that use the tag [tagId], in list order. Derived from
  /// [visibleNotesProvider] and [tagsProvider] (notes store tag names; tags
  /// map ids to names, matched ignoring case), so renaming a tag keeps the
  /// filter working. One instance per tag id, auto-disposed when unused.

  TagNotesProvider call(String tagId) =>
      TagNotesProvider._(argument: tagId, from: this);

  @override
  String toString() => r'tagNotesProvider';
}
