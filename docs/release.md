# Releasing NoteVault (Android)

## Version

The only place the version lives is `pubspec.yaml`:

```yaml
version: 1.0.0+1   # <versionName>+<versionCode>
```

- Android: `android/app/build.gradle.kts` reads it through
  `flutter.versionName` / `flutter.versionCode`. Do not hard-code it in Gradle.
- In the app: Settings → About shows the installed version name, read from the
  package metadata (`appVersionProvider`, `package_info_plus`).
- Every Google Play upload needs a higher versionCode: bump the number after
  `+` (e.g. `1.0.1+2`). The name follows semantic versioning.

## Signing

Release builds are signed with the upload key described in
`android/key.properties` (git-ignored, like `*.jks` / `*.keystore`):

```properties
storeFile=/absolute/path/to/upload-keystore.jks
storePassword=...
keyAlias=upload
keyPassword=...
```

Create the upload key once (keep the file and passwords safe and backed up;
never commit them):

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Without `key.properties` the release build falls back to the debug key and
Gradle prints a warning. Such a bundle cannot be uploaded to Google Play.

With Play App Signing, Google re-signs the app with its app signing key. For
Google Sign-In to work, add the SHA-1 and SHA-256 of both the upload key and
the Play app signing key (shown on the Play Console "App integrity" page) to
the Firebase Android app `com.ashiq.notevalult`.

## Build

```bash
flutter clean
flutter pub get
flutter analyze
flutter test
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`.

The `sqlite3` package downloads a prebuilt SQLite library from GitHub
(`release-assets.githubusercontent.com`) during the build. The machine must be
able to reach it (it is cached until `flutter clean`).

## Launcher icon

Sources live in `assets/branding/` (not bundled into the app). Regenerate the
Android icons with:

```bash
dart run flutter_launcher_icons
```

`notevault_icon.png` (512×512) is also the Google Play store icon.
