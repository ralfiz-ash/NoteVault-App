// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The signed-in user's settings (theme mode and notes sort): the single
/// source of truth for both. The app theme and the notes list read it with
/// `select`, so a theme change does not refilter notes and a sort change
/// does not rebuild the theme.
///
/// Lifecycle:
/// - signed out: the defaults, nothing stored;
/// - user signs in (or the app starts with a session): that user's saved
///   settings are loaded from their own database (defaults if none or if a
///   stored value is invalid);
/// - sign-out / another user: rebuilt from scratch, so one user's settings
///   never show for another.
///
/// Changes apply at once and are then saved locally (never synced, works
/// offline). Not keepAlive: the app root always watches it.

@ProviderFor(Settings)
final settingsProvider = SettingsProvider._();

/// The signed-in user's settings (theme mode and notes sort): the single
/// source of truth for both. The app theme and the notes list read it with
/// `select`, so a theme change does not refilter notes and a sort change
/// does not rebuild the theme.
///
/// Lifecycle:
/// - signed out: the defaults, nothing stored;
/// - user signs in (or the app starts with a session): that user's saved
///   settings are loaded from their own database (defaults if none or if a
///   stored value is invalid);
/// - sign-out / another user: rebuilt from scratch, so one user's settings
///   never show for another.
///
/// Changes apply at once and are then saved locally (never synced, works
/// offline). Not keepAlive: the app root always watches it.
final class SettingsProvider
    extends $AsyncNotifierProvider<Settings, AppSettings> {
  /// The signed-in user's settings (theme mode and notes sort): the single
  /// source of truth for both. The app theme and the notes list read it with
  /// `select`, so a theme change does not refilter notes and a sort change
  /// does not rebuild the theme.
  ///
  /// Lifecycle:
  /// - signed out: the defaults, nothing stored;
  /// - user signs in (or the app starts with a session): that user's saved
  ///   settings are loaded from their own database (defaults if none or if a
  ///   stored value is invalid);
  /// - sign-out / another user: rebuilt from scratch, so one user's settings
  ///   never show for another.
  ///
  /// Changes apply at once and are then saved locally (never synced, works
  /// offline). Not keepAlive: the app root always watches it.
  SettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsHash();

  @$internal
  @override
  Settings create() => Settings();
}

String _$settingsHash() => r'8e82c22481d43224fcb0d8eda834e5d126badc41';

/// The signed-in user's settings (theme mode and notes sort): the single
/// source of truth for both. The app theme and the notes list read it with
/// `select`, so a theme change does not refilter notes and a sort change
/// does not rebuild the theme.
///
/// Lifecycle:
/// - signed out: the defaults, nothing stored;
/// - user signs in (or the app starts with a session): that user's saved
///   settings are loaded from their own database (defaults if none or if a
///   stored value is invalid);
/// - sign-out / another user: rebuilt from scratch, so one user's settings
///   never show for another.
///
/// Changes apply at once and are then saved locally (never synced, works
/// offline). Not keepAlive: the app root always watches it.

abstract class _$Settings extends $AsyncNotifier<AppSettings> {
  FutureOr<AppSettings> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AppSettings>, AppSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AppSettings>, AppSettings>,
              AsyncValue<AppSettings>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The current theme preference (defaults while loading).

@ProviderFor(themeModePreference)
final themeModePreferenceProvider = ThemeModePreferenceProvider._();

/// The current theme preference (defaults while loading).

final class ThemeModePreferenceProvider
    extends
        $FunctionalProvider<
          ThemeModePreference,
          ThemeModePreference,
          ThemeModePreference
        >
    with $Provider<ThemeModePreference> {
  /// The current theme preference (defaults while loading).
  ThemeModePreferenceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeModePreferenceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeModePreferenceHash();

  @$internal
  @override
  $ProviderElement<ThemeModePreference> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ThemeModePreference create(Ref ref) {
    return themeModePreference(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThemeModePreference value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThemeModePreference>(value),
    );
  }
}

String _$themeModePreferenceHash() =>
    r'df2a71432b2bd7e505caf8d88ca8bb9ab8c87b67';

/// The current notes sort (defaults while loading).

@ProviderFor(noteSortSetting)
final noteSortSettingProvider = NoteSortSettingProvider._();

/// The current notes sort (defaults while loading).

final class NoteSortSettingProvider
    extends $FunctionalProvider<NoteSort, NoteSort, NoteSort>
    with $Provider<NoteSort> {
  /// The current notes sort (defaults while loading).
  NoteSortSettingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'noteSortSettingProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$noteSortSettingHash();

  @$internal
  @override
  $ProviderElement<NoteSort> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  NoteSort create(Ref ref) {
    return noteSortSetting(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NoteSort value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NoteSort>(value),
    );
  }
}

String _$noteSortSettingHash() => r'264a20f68a9eb98d0e1dde6b54ed441f42b401f4';
