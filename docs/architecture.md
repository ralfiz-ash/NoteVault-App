# NoteVault architecture

NoteVault uses **feature-first Clean Architecture**. Code is grouped by
feature, and each feature has three layers.

```
lib/
├── main.dart                     calls bootstrap()
├── app/                          composition root (may see every layer)
│   ├── bootstrap.dart            config, logger, error hooks, root ProviderScope
│   ├── app.dart                  NoteVaultApp (MaterialApp.router)
│   ├── di/core_providers.dart    @riverpod providers for config and logger
│   └── router/                   go_router provider, route paths, error screen
├── core/                         shared, feature-agnostic code
│   ├── config/app_config.dart    non-secret config (--dart-define APP_ENV)
│   ├── database/                 Drift AppDatabase, tables, DB exception mapper
│   ├── utils/                    Clock, IdGenerator
│   ├── errors/                   sealed Failure, ExceptionMapper, guardFailures
│   ├── logging/app_logger.dart   AppLogger, ConsoleLogger, redaction
│   ├── usecase/usecase.dart      UseCase<Output, Input> base + NoParams
│   └── theme/app_theme.dart      Golden taupe light/dark themes
└── features/
    ├── auth/        (user, sign-out, auth state)
    ├── notes/       (note, local-first note storage; search/filter later)
    ├── folders/     (folders)
    ├── tags/        (tags)
    ├── settings/    (theme mode, note sort order)
    └── sync/        (connectivity now; pending-note upload later)
        ├── domain/
        │   ├── entities/         plain Dart business objects
        │   ├── repositories/     abstract contracts (interfaces)
        │   └── usecases/         one application action per class
        ├── data/
        │   ├── models/           serializable forms of entities (toMap/fromMap/toEntity)
        │   ├── datasources/      abstract boundaries to SDKs (local DB, Firestore, ...)
        │   └── repositories/     implement the domain contracts using datasources
        └── presentation/
            ├── screens/          full pages
            ├── widgets/          feature-specific widgets
            ├── providers/        Riverpod providers / notifiers
            └── state/            UI state classes
```

## Dependency direction

```
presentation ──▶ domain ◀── data          core ◀── everything
```

| Layer | May import | Must NOT import |
|---|---|---|
| `domain` | `core`, other features' `domain` | Flutter, Riverpod, Firebase, DB/plugin SDKs, any `data` or `presentation` |
| `data` | own and other features' `domain`, `core` | Flutter widgets, Riverpod, any `presentation`, another feature's `data` |
| `presentation` | `domain`, `core`, own `presentation` | `data`, infrastructure SDKs, another feature's `presentation` |
| `core` | itself | `features/`, `app/` |
| `app` | everything | (it is the composition root) |
| feature `presentation` | `app/di/` (DI providers only) | the rest of `app/` |
| feature `domain` / `data` | - | `app/` |

Presentation never talks to `data` directly. It depends on repository
*contracts* and use cases from `domain`. The concrete `data` classes are
connected to those contracts in the **composition root** (`lib/app/di/`), which
is the only place allowed to see both sides. Today it exposes `appConfigProvider`
and `appLoggerProvider`; repositories and data sources are added there in later
phases.

These rules are enforced by `test/architecture/dependency_rules_test.dart`:
a wrong import fails `flutter test`.

## Responsibilities

- **Entities** (`Note`, `Folder`, `AppUser`, `AppSettings`): immutable, pure
  Dart. Settings use domain enums (`ThemeModePreference`) rather than Flutter's
  `ThemeMode`; presentation maps them.
- **Repository contracts**: what the app needs, expressed in entities
  (`Stream<List<Note>> watchNotes()`), never in SDK types.
- **Use cases**: single actions implementing `UseCase<Output, Input>`. They
  contain business rules and call repository contracts.
- **Models**: the stored/transferred shape. Dates are epoch milliseconds and
  enums are stored by name, so the same map works for the local DB and the
  cloud without SDK types (no Firestore `Timestamp` in models).
- **Data sources**: thin wrappers around one SDK each. SDK exceptions are
  converted to `Failure` types by the repository implementation.
- **Repository implementations**: map models to entities and coordinate data
  sources (for notes: local database first, Firestore as sync target).
- **Providers / notifiers / state**: Riverpod lives only in `presentation`.

## Core foundation (Phase 2)

- **Riverpod 3** with `riverpod_generator` (`@riverpod`), `riverpod_lint`
  (enabled under `plugins:` in `analysis_options.yaml`) and `build_runner`.
  Regenerate with `dart run build_runner build`. The generated `*.g.dart`
  files are committed and must never be edited by hand.
- **Dependency injection**: dependencies are providers, overridden in
  `bootstrap()` and in tests (`ProviderScope(overrides: ...)`,
  `createContainer(overrides: ...)` in `test/helpers`).
- **Routing**: `go_router`, one `GoRouter` provider in `lib/app/router/`.
- **Errors**: data sources throw anything; repositories call `guardFailures`
  with an `ExceptionMapper`, so callers only see a `Failure`.
- **Logging**: use `AppLogger` (never `print`, enforced by lint). Structured
  `data` has sensitive keys masked; never put secrets in log messages.
- **Config**: `AppConfig` from `--dart-define` (for example
  `--dart-define=APP_ENV=prod`). No secrets in code.
- **Model generation (freezed / json_serializable) is deferred**: entities and
  models are small, hand-written immutable classes. Revisit in the Local
  Database phase when DTO serialization grows.

## Local database (Phase 3)

**Drift (SQLite)** is the local database: typed queries, relational integrity
(notes, folders, tags), reactive streams, migrations, and in-memory databases
for tests. It uses `build_runner`, which the project already has.

```
Presentation (later)
      |
Domain: Note / Folder / Tag + NoteRepository / FolderRepository / TagRepository
      ^
Data:  *RepositoryImpl  ->  *LocalDataSource (interface)  ->  Drift*LocalDataSource
                                                                   |
                                                         core/database/AppDatabase
```

- **Schema** (`lib/core/database/`): `notes`, `folders`, `tags` (unique, case
  insensitive name) and `note_tags` (many-to-many). Dates are epoch
  milliseconds; the data layer returns them as UTC. Deleting a folder keeps
  its notes (`ON DELETE SET NULL`); deleting a note or tag removes its links
  (`ON DELETE CASCADE`). Foreign keys are enabled per connection.
- **Separation**: only `Drift*LocalDataSource` classes and `AppDatabase` know
  about Drift. Data sources speak in `*Model` classes; repositories convert
  models to domain entities. Domain and presentation may not import
  `core/database/` (enforced by the architecture test).
- **Failures**: repositories wrap data source calls in `guardFailures` /
  `guardFailureStream`. Missing records become `NotFoundFailure`; anything the
  database throws becomes `LocalDatabaseFailure`.
- **Timestamps**: `updateNote` keeps the stored id and `createdAt` and sets
  `updatedAt` from the injected `Clock`.
- **Ids**: generated on the device (`IdGenerator`, UUID v4) so records can be
  created offline without clashes.
- **Dependency injection**: `lib/app/di/database_providers.dart` and
  `repository_providers.dart` build `appDatabase -> data source -> repository`.
  Override any link in tests (`appDatabaseProvider.overrideWithValue(...)`).
- **Tests** use `NativeDatabase.memory()` (`test/helpers/test_database.dart`),
  never the real database file.
- **Platforms**: Android, iOS and Web, all through the same Drift code.
  - Android / iOS: a SQLite file in the app's documents directory.
  - Web: SQLite compiled to WebAssembly (shared worker + IndexedDB, or OPFS
    when the browser allows). It needs two files in `web/`:
    `sqlite3.wasm` and `drift_worker.js`. Both are committed and produced by
    `bash tool/build_web_db_assets.sh` (the worker is compiled from
    `tool/drift_worker.dart` against the locked drift version; the wasm is
    copied from the drift package). `sqlite3` is a direct dependency purely so
    its version stays in step with `web/sqlite3.wasm`: a mismatched wasm fails
    at runtime with a `LinkError`. After upgrading `drift` or `sqlite3`, re-run
    the script and test on a real browser.
- **Tags are independent entities.** A tag is created the first time a note
  uses it and then stays available. Removing a tag from a note, or deleting a
  note, never deletes the tag, and there is intentionally no automatic orphan
  cleanup. A tag is removed only by an explicit `TagRepository.deleteTag`,
  which also unlinks it from every note. (Creating a tag without attaching it
  to a note is not exposed yet; that belongs to the tag-management phase.)
- **Dates are UTC.** Timestamps are stored as epoch milliseconds, and the data
  layer always returns UTC `DateTime`s to the domain. The domain never converts
  to local time. The presentation layer converts for display only, with
  `dateTime.toLocal()` before formatting (to be done in the notes UI phase).

### Prepared for sync (not implemented)

Stable client-generated ids, `createdAt`/`updatedAt` on every note, and the
folder/tag relations already exist. Sync metadata (for example a sync state or
deletion marker) is deliberately **not** in the schema yet: it will be added by
a Drift migration (`schemaVersion` 2) in the sync phases, once the design is
known.

## Firebase foundation (Phase 4)

Firebase is infrastructure: only the data layer, `core/firebase/` and the
composition root (`lib/app/`) import Firebase or Google Sign-In packages.
Domain and presentation may not (enforced by the architecture test).
Console setup and remaining manual steps: `docs/firebase-setup.md`.

```
Domain:  AuthRepository                     NoteRemoteRepository
            ^                                  ^
Data:    AuthRepositoryImpl                 NoteRemoteRepositoryImpl
            |  AuthExceptionMapper             |  FirestoreExceptionMapper
         AuthRemoteDataSource               NoteRemoteDataSource
            |                                  |
         FirebaseAuthRemoteDataSource       FirestoreNoteRemoteDataSource
         (FirebaseAuth + GoogleIdTokenSource)  (FirebaseFirestore)
```

- **Initialisation**: `bootstrap()` calls `FirebaseInitializer.initialize()`
  once, before `runApp`, using `lib/firebase_options.dart`. A failure is
  logged and the app still starts (notes are local-first).
- **Auth**: email/password sign-in and registration, password reset email,
  Google sign-in and sign-out, current user and auth state stream. Firebase
  `User` is mapped to `AppUserModel` and then to the domain `AppUser`. Google
  sign-in uses the native account picker on Android/iOS (ID token exchanged
  for a Firebase credential) and Firebase's popup on the web. No auth UI yet.
- **Remote notes**: `users/{uid}/notes/{noteId}` documents with the same fields
  as the local note; dates are Firestore `Timestamp`s in the document and UTC
  `DateTime`s everywhere else (`NoteFirestoreMapper`). Values are stored
  exactly as given. Not connected to the local database: no sync yet.
- **Errors**: `AuthExceptionMapper` (Firebase Auth + Google Sign-In) and
  `FirestoreExceptionMapper` turn SDK exceptions into the existing `Failure`
  types; a new `CancelledFailure` covers a user closing a sign-in flow.
- **DI**: `lib/app/di/firebase_providers.dart` exposes the SDK instances,
  data sources, mappers and repositories (typed by their abstractions).
- **Security rules**: `firestore.rules`, owner-only notes, deny by default.
- **Tests** use fakes (`test/helpers/fake_firebase_auth.dart`,
  `fake_cloud_firestore`), never the live project.

## Riverpod architecture (Phase 5)

Riverpod is the dependency-injection and state layer. Generated providers
(`@riverpod`) only; run `dart run build_runner build` after changes.

```
ProviderScope (bootstrap: config, logger, retry policy)
 |
 |-- app/di: infrastructure + repositories (typed by domain interfaces)
 |     appDatabase -> note/folder/tag data sources -> repositories
 |     FirebaseAuth, GoogleSignIn -> authRepository
 |     FirebaseFirestore -> noteRemoteRepository
 |     Connectivity -> connectivityRepository
 |
 '-- feature presentation providers (watch repositories, never data classes)
       authStateProvider          Stream<AuthState>   keepAlive
       notesProvider              Stream<List<Note>>  keepAlive
         |-- noteProvider(id)               Future<Note>        autoDispose
         '-- folderNotesProvider(folderId)  Future<List<Note>>  autoDispose
       noteMutationsProvider      AsyncNotifier<NoteMutationResult?> autoDispose
       settingsProvider           Notifier<AppSettings>              keepAlive
       connectionStatusProvider   Stream<ConnectivityStatus>         keepAlive
```

- **Why presentation may import `app/di`**: providers there are typed by
  domain interfaces (`NoteRepository`, `AuthRepository`, ...), so screens and
  notifiers get dependencies without importing data classes. Nothing else in
  `app/` is visible to features (architecture test).
- **Lifecycles**: `keepAlive` only for app-wide state that must survive
  without listeners (session, shared notes cache, settings, network status);
  each one documents why. Per-screen and per-id providers are auto-disposed.
  `ref.onDispose` closes resources the providers create (database, router).
- **Async state**: `AsyncValue` everywhere (loading / data / error); an empty
  list is data. Mutations expose `AsyncValue<NoteMutationResult?>`: `null` is
  idle, a result is success. Retry with `ref.invalidate(...)`.
- **Retry policy** (`lib/app/provider_retry.dart`): Riverpod 3 retries failed
  providers by default; NoteVault retries only `NetworkFailure` (3 times with
  backoff). Other failures show immediately.
- **ref usage**: `ref.watch` to build UI and in providers that depend on
  others; `ref.read` in callbacks and notifier methods; `ref.listen` for side
  effects (SnackBar, navigation). Example: `PlaceholderHomeScreen`.
- **Not yet**: settings persistence (Settings phase), user-dependent resets
  on logout (later), sort/search/filter (Search phase), sync.
- **Tests**: `createContainer(overrides: ...)` and `appTestOverrides()` in
  `test/helpers/`, with fakes in `test/helpers/fake_repositories.dart`.

## Adding a feature

1. Create `features/<name>/{domain,data,presentation}` with the subfolders above.
2. Define entities, a repository contract and use cases in `domain`.
3. Add models, a data source interface and a repository implementation in `data`.
4. Build screens and Riverpod providers in `presentation`.
5. Run `flutter test`; the architecture test will flag wrong imports.
