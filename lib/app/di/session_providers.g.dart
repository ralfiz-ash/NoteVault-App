// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The signed-in user's id, or `null` when signed out. This is the boundary
/// for everything user-specific: providers holding a user's data `watch` it,
/// so they are rebuilt (and the previous user's state is dropped) whenever
/// the user signs out or a different user signs in.
///
/// Firebase Authentication is the only source of truth (it also restores the
/// session after an app restart); nothing is stored by the app itself.
///
/// keepAlive: it is the root of the user-scoped dependency graph and must not
/// be re-created while the app runs.

@ProviderFor(currentUserId)
final currentUserIdProvider = CurrentUserIdProvider._();

/// The signed-in user's id, or `null` when signed out. This is the boundary
/// for everything user-specific: providers holding a user's data `watch` it,
/// so they are rebuilt (and the previous user's state is dropped) whenever
/// the user signs out or a different user signs in.
///
/// Firebase Authentication is the only source of truth (it also restores the
/// session after an app restart); nothing is stored by the app itself.
///
/// keepAlive: it is the root of the user-scoped dependency graph and must not
/// be re-created while the app runs.

final class CurrentUserIdProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, Stream<String?>>
    with $FutureModifier<String?>, $StreamProvider<String?> {
  /// The signed-in user's id, or `null` when signed out. This is the boundary
  /// for everything user-specific: providers holding a user's data `watch` it,
  /// so they are rebuilt (and the previous user's state is dropped) whenever
  /// the user signs out or a different user signs in.
  ///
  /// Firebase Authentication is the only source of truth (it also restores the
  /// session after an app restart); nothing is stored by the app itself.
  ///
  /// keepAlive: it is the root of the user-scoped dependency graph and must not
  /// be re-created while the app runs.
  CurrentUserIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentUserIdProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentUserIdHash();

  @$internal
  @override
  $StreamProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<String?> create(Ref ref) {
    return currentUserId(ref);
  }
}

String _$currentUserIdHash() => r'cd7571f6b13dd58f3428adb6208600aa97e623c4';
