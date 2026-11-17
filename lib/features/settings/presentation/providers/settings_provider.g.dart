// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The signed-in user's settings (theme mode and notes sort): a synchronous
/// `NotifierProvider` and the single source of truth for both. The app theme
/// and the notes list read it with `select`, so a theme change does not
/// refilter notes and a sort change does not rebuild the theme.
///
/// Lifecycle:
/// - signed out: the defaults, nothing stored;
/// - user signs in (or the app starts with a session): the state is the
///   defaults at once and that user's saved settings replace it as soon as
///   they are read from their own database ([ready] completes then);
/// - sign-out / another user: rebuilt from scratch (a new notifier), so one
///   user's settings never show for another; a late load for the previous
///   user is ignored.
///
/// Changes apply at once and are then saved locally (never synced, works
/// offline). Not keepAlive: the app root always watches it.

@ProviderFor(Settings)
final settingsProvider = SettingsProvider._();

/// The signed-in user's settings (theme mode and notes sort): a synchronous
/// `NotifierProvider` and the single source of truth for both. The app theme
/// and the notes list read it with `select`, so a theme change does not
/// refilter notes and a sort change does not rebuild the theme.
///
/// Lifecycle:
/// - signed out: the defaults, nothing stored;
/// - user signs in (or the app starts with a session): the state is the
///   defaults at once and that user's saved settings replace it as soon as
///   they are read from their own database ([ready] completes then);
/// - sign-out / another user: rebuilt from scratch (a new notifier), so one
///   user's settings never show for another; a late load for the previous
///   user is ignored.
///
/// Changes apply at once and are then saved locally (never synced, works
/// offline). Not keepAlive: the app root always watches it.
final class SettingsProvider extends $NotifierProvider<Settings, AppSettings> {
  /// The signed-in user's settings (theme mode and notes sort): a synchronous
  /// `NotifierProvider` and the single source of truth for both. The app theme
  /// and the notes list read it with `select`, so a theme change does not
  /// refilter notes and a sort change does not rebuild the theme.
  ///
  /// Lifecycle:
  /// - signed out: the defaults, nothing stored;
  /// - user signs in (or the app starts with a session): the state is the
  ///   defaults at once and that user's saved settings replace it as soon as
  ///   they are read from their own database ([ready] completes then);
  /// - sign-out / another user: rebuilt from scratch (a new notifier), so one
  ///   user's settings never show for another; a late load for the previous
  ///   user is ignored.
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

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppSettings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppSettings>(value),
    );
  }
}

String _$settingsHash() => r'e8688a66fca89d88dec7a3affb3927df7de6bf7c';

/// The signed-in user's settings (theme mode and notes sort): a synchronous
/// `NotifierProvider` and the single source of truth for both. The app theme
/// and the notes list read it with `select`, so a theme change does not
/// refilter notes and a sort change does not rebuild the theme.
///
/// Lifecycle:
/// - signed out: the defaults, nothing stored;
/// - user signs in (or the app starts with a session): the state is the
///   defaults at once and that user's saved settings replace it as soon as
///   they are read from their own database ([ready] completes then);
/// - sign-out / another user: rebuilt from scratch (a new notifier), so one
///   user's settings never show for another; a late load for the previous
///   user is ignored.
///
/// Changes apply at once and are then saved locally (never synced, works
/// offline). Not keepAlive: the app root always watches it.

abstract class _$Settings extends $Notifier<AppSettings> {
  AppSettings build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AppSettings, AppSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AppSettings, AppSettings>,
              AppSettings,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The current theme preference.

@ProviderFor(themeModePreference)
final themeModePreferenceProvider = ThemeModePreferenceProvider._();

/// The current theme preference.

final class ThemeModePreferenceProvider
    extends
        $FunctionalProvider<
          ThemeModePreference,
          ThemeModePreference,
          ThemeModePreference
        >
    with $Provider<ThemeModePreference> {
  /// The current theme preference.
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
    r'3a2f5dc12be4fa95d86bedef77b5c24483f1190a';

/// The current notes sort.

@ProviderFor(noteSortSetting)
final noteSortSettingProvider = NoteSortSettingProvider._();

/// The current notes sort.

final class NoteSortSettingProvider
    extends $FunctionalProvider<NoteSort, NoteSort, NoteSort>
    with $Provider<NoteSort> {
  /// The current notes sort.
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

String _$noteSortSettingHash() => r'5afe37ca230bc80a144749927a33e5076797319b';
