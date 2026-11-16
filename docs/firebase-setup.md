# Firebase setup

NoteVault uses the Firebase project **`notevault-e0ea6`** (owner account:
the NoteVault Firebase/Google account). Configuration follows the standard
FlutterFire approach.

## What is already done

| Item | State |
|---|---|
| Android app `com.ashiq.notevalult` | Registered; `android/app/google-services.json`; Google services Gradle plugin applied |
| iOS app `com.ashiq.notevalult` | Registered; `ios/Runner/GoogleService-Info.plist` added to the Runner target |
| Web app | Registered |
| Dart options | `lib/firebase_options.dart` (generated, do not edit) |
| Cloud Firestore | `(default)` database, Native mode, location `nam5` (permanent) |
| Security rules | `firestore.rules` deployed: owner-only `users/{uid}/notes/{noteId}`, everything else denied |
| CLI project link | `.firebaserc` (default project) and `firebase.json` |

To regenerate the config after changes in the console (for example after
enabling Google sign-in or adding SHA fingerprints):

```bash
flutterfire configure --project=notevault-e0ea6 --platforms=android,ios,web --android-package-name=com.ashiq.notevalult --ios-bundle-id=com.ashiq.notevalult --out=lib/firebase_options.dart --yes
```

Deploy rule changes with:

```bash
firebase deploy --only firestore:rules
```

## Manual steps still required (Firebase console)

These need a person in the Firebase console; the CLI cannot do them.

1. **Enable Authentication.** Console -> Build -> Authentication -> Get
   started. Until then every auth call fails with `CONFIGURATION_NOT_FOUND`
   (the app shows a generic "Authentication failed" message).
2. **Enable sign-in providers.** Authentication -> Sign-in method:
   - Email/Password -> Enable.
   - Google -> Enable, choose the project support email, Save.
3. **Android Google sign-in:** add the app's SHA-1 (and SHA-256)
   fingerprints. Project settings -> Your apps -> Android app -> Add
   fingerprint. For the local debug keystore:

   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```

   Add the release/Play signing fingerprints too before shipping.
4. **Re-run `flutterfire configure`** (command above) after steps 2-3, so
   `google-services.json` and `GoogleService-Info.plist` contain the new OAuth
   clients.
5. **iOS Google sign-in:** after step 4, `GoogleService-Info.plist` contains
   `CLIENT_ID` and `REVERSED_CLIENT_ID`. Add to `ios/Runner/Info.plist`:

   ```xml
   <key>GIDClientID</key>
   <string>CLIENT_ID value</string>
   <key>CFBundleURLTypes</key>
   <array>
     <dict>
       <key>CFBundleURLSchemes</key>
       <array><string>REVERSED_CLIENT_ID value</string></array>
     </dict>
   </array>
   ```

6. **Web Google sign-in:** Authentication -> Settings -> Authorized domains
   must include every domain the web app is served from (`localhost` is there
   by default; add the production domain when deploying).

## About the config values in the repository

`firebase_options.dart`, `google-services.json` and `GoogleService-Info.plist`
contain API keys and app ids. These are client identifiers, not secrets: every
installed app or loaded web page has them. Data is protected by Firebase
Authentication and the Firestore security rules, not by hiding these files.
Recommended hardening: in Google Cloud console -> APIs & Services ->
Credentials, restrict each API key to its app (Android package + SHA-1, iOS
bundle id, web HTTP referrers). No private credentials (service accounts,
admin keys) are, or should ever be, committed.
