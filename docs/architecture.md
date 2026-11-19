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

## Authentication (Phase 6)

```
Login / Register / Forgot password screens (presentation)
   | ref.read(authControllerProvider.notifier) / passwordResetControllerProvider
   v
Use cases: SignInWithEmail, RegisterWithEmail, SignInWithGoogle,
           SendPasswordReset, SignOut, ObserveAuthState   (domain)
   v
AuthRepository -> AuthRepositoryImpl -> FirebaseAuthRemoteDataSource (data)
```

- **Validation**: `AuthValidators` (domain, pure Dart) is the single set of
  rules. Forms use it for field messages before anything is sent; the use
  cases call it again as a safety net (`ValidationFailure`).
- **Controllers**: `AuthController` (sign-in, register, Google, sign-out) and
  `PasswordResetController` expose `AsyncValue`. While loading, buttons and
  fields are disabled and repeated requests are ignored. Errors are shown
  once, by the visible screen only; a cancelled Google sign-in shows nothing.
  Passwords go straight to the use case and are never kept in state, stored
  or logged.
- **Routing guard** (`lib/app/router/auth_redirect.dart`): one redirect for
  all routes, re-run when `authStateProvider` changes. Session unknown ->
  splash; signed out -> `/login` (with `/login/register` and
  `/login/forgot-password`); signed in -> the app. Screens do not check auth
  themselves and do not navigate after sign-in.
- **Session persistence**: Firebase Authentication restores the session on
  restart; the app stores nothing.
- **User isolation**: `currentUserIdProvider` (app/di) is the boundary.
  - Each user has their own local database file (`notevault_<uid>`).
    `appDatabaseProvider` watches the user id, so signing out or switching
    users closes the old database and rebuilds every repository and provider
    on top of it.
  - `notesProvider` is an empty list while signed out, so a reloading screen
    can never show the previous user's notes. Settings reset per user.
  - New user-specific providers must watch `currentUserIdProvider` (directly
    or through the database) instead of assuming a signed-in user.
  - Notes created before Phase 6 were in the shared `notevault` file and are
    not migrated (pre-release data).

## Notes CRUD (Phase 7)

```
NotesListScreen ---- ref.watch(visibleNotesProvider) <- notesProvider <- ObserveNotes
NoteViewScreen ----- ref.watch(noteProvider(id))       (derived from notesProvider)
NoteEditorScreen --- CreateNoteController / UpdateNoteController (AsyncNotifier)
Delete (list/view) - DeleteNoteController + PendingNoteDeletions (optimistic)
        each controller -> use case -> NoteRepository -> local data source -> Drift
```

- **Use cases**: `CreateNote` (draft -> validated note with a new id and UTC
  timestamps), `UpdateNote`, `DeleteNote`, `GetNote`, `GetNotes`,
  `ObserveNotes`. `NoteDraft` (domain) is the editable part of a note;
  `NoteValidators` holds the rules (title required, at most 200 characters;
  content may be empty; tags trimmed, de-duplicated, at most 20).
- **Reads**: the list and `noteProvider(id)` come from one live database
  watch, so every successful mutation shows up everywhere without manual
  refresh, and a deleted note's screen notices it is gone.
  `noteProvider(id)` filters the shared list instead of running its own
  query (one source of truth, no duplicate copies).
- **Optimistic delete**: the id goes into `PendingNoteDeletions`, so the list
  hides it at once; on failure it is removed again (the note reappears) and
  the list shows "Unable to delete note". Create and update are not
  optimistic: the local database answers immediately and the list updates
  from it, so a failed save never leaves a phantom note.
- **Editor**: one screen for new and edit. Text controllers, folder, tags and
  the saved baseline live in the screen's State (gone when it closes).
  Unsaved changes = current values differ from the baseline (the note as
  loaded, so loading is not a change). Leaving with changes (back button,
  system back, gesture) asks Stay / Discard via `PopScope`.
- **Folders/tags in the editor**: pick a folder (or create one by name);
  type tags or reuse suggested existing ones. Tags stay independent.
- **Dates**: stored and passed around as UTC; `formatDateTime`
  (`core/presentation`) converts with `toLocal()` only for display.
- **Cross-feature UI**: feature presentation may use another feature's
  `presentation/providers` and `presentation/state` (its public API), never
  its screens or widgets (architecture test).
- **Offline**: notes CRUD only touches the local database; Firestore is not
  used (sync comes later).

## Folders, tags and tag colours (Phase 8)

- **Folders**: create, rename and delete from the Folders screen (drawer ->
  Folders -> edit); assign in the note editor. Deleting a folder keeps its
  notes: one `UPDATE notes SET folder_id = NULL` (no per-note writes, note
  dates untouched), then the folder row is deleted, in one transaction.
- **Tags**: independent entities, unique by name ignoring case. Created on
  the Tags screen (name + colour) or implicitly when a note uses a new name
  (default colour). Add/remove on the note screen (`AddTagToNote`,
  `RemoveTagFromNote`) or in the editor. Removing from a note only unlinks.
  Deleting a tag unlinks it from all notes (explicit statement, so watchers
  refresh) and keeps the notes.
- **Tag colours**: stored as `"#RRGGBB"` (`Tag.colorValue`, column
  `tags.color`, schema version 2 with a migration that gives existing tags
  the default). `TagColors` (domain) holds the palette, validation and the
  default; invalid stored values show as the default. Only
  `core/presentation/tag_chip.dart` turns the string into a Flutter `Color`.
  `tagsProvider` is the single source; chips look colours up by name
  (`tagsByNameProvider`), so a colour change shows everywhere at once.
- **Filtering and counts** (all derived from the notes already in memory; no
  query per folder or tag):
  - `folderNotesProvider(folderId)` (`null` = no folder) and
    `tagNotesProvider(tagId)`: one auto-disposed instance per id.
  - `filteredNotesProvider` picks one of them from the list's
    `NotesFilterController` (all / folder / no folder / tag), set from the
    drawer.
  - `folderNoteCountsProvider` and `tagNoteCountsProvider`: one pass over the
    notes.

## Search and derived state (Phase 9)

```
notesProvider (database watch)
   -> visibleNotesProvider (minus deletions in progress)
        |-> folderNoteCountsProvider / tagNoteCountsProvider   (counts)
        '-> filteredNotesProvider = noteQuery.apply(visible notes)   (list)
                 noteQueryProvider <- noteSearchController (debounced)
                                   <- notesFilterController (folder, tag)
                                   <- settingsProvider.select(noteSort)
                                   <- tagsProvider.select(selected tag name)
```

- **One source, derived views**: the list, the counts and the filters all
  come from the same notes in memory; nothing filtered or counted is stored.
  Typing never queries the database.
- **`NoteQuery` (domain, pure Dart)** is the only matching/sorting logic:
  case-insensitive substring search in title and content, folder scope
  (any / none / one folder), tag (by name, ignoring case), combined with AND;
  `NoteSort` = field (edited, created, title) + direction, comparing the
  stored UTC instants, ties broken by id. Widgets never filter or sort.
- **Debounce**: `NoteSearchController.onInput` restarts a 300 ms timer
  (`searchDebounceProvider`); only the last text is applied, unchanged text
  causes no update, and the timer is cancelled on dispose or user change.
  "Clear" applies immediately (`setNow`).
- **Rebuild scoping**: `noteQueryProvider` watches only the sort (not the
  theme) and only the selected tag's name (not every tag colour); `NoteQuery`
  has value equality, so unchanged inputs stop there. Tests count updates
  with a `ProviderObserver`.
- **Sort setting**: `AppSettings.noteSort` (persisted in the Settings phase);
  the list's sort sheet changes it.
- **Empty states**: "No notes yet" (no notes at all) is separate from "No
  notes found" (filters/search match nothing), with a specific message for
  search, folder, tag or combinations. Errors stay errors.

## Offline-first sync (Phase 10)

```
UI -> use case -> NoteRepository ── one local transaction ──┐
                                   note row + sync_queue row ┘
                                              |
SyncController (when to sync) -> SyncPendingChanges -> SyncRepository
   triggers: sign-in/start, offline->online, new queued changes (2 s),
             failed run (30 s doubling to 5 min), Retry button
                                              |
   for each queued note: claim -> upsert current local note / delete
                         -> remove from queue (or mark failed, keep)
                                              |
                     NoteRemoteRepository -> Firestore users/{uid}/notes/{id}
```

- **Local first**: every note change (and changes caused by deleting a
  folder or renaming/deleting a tag) is written locally and recorded in the
  `sync_queue` table in the same transaction. The UI never waits for the
  network; offline CRUD works unchanged.
- **Persistent queue** (`core/database/sync_queue_store.dart`, schema 3):
  one row per note with operation, status (pending/syncing/failed), version,
  retry count and last error. No copy of the note: the current local note is
  uploaded, so the latest state always wins. The migration queued notes that
  existed before sync.
- **Merging**: create+update -> create, update+update -> update,
  create+delete -> dropped only if the create was never attempted,
  otherwise delete; any+delete -> delete. Each change bumps the version.
- **Safety**:
  - Idempotent: upload = Firestore `set` on the note's own id; delete
    succeeds if already gone. Retries never duplicate documents.
  - Single flight: `SyncRepositoryImpl` shares a running sync with any new
    call and runs once more afterwards; items are also claimed by version in
    the database, so one item is never uploaded twice at once.
  - A change during an upload keeps the row pending (version moved on); the
    newer state goes next. Failures keep the row (failed + error); local data
    is never rolled back. Rows left "syncing" by a killed app are released at
    the next run. Writes time out after 20 s and are retried later.
- **Conflict strategy**: see "Cross-device sync" below.
- **UI**: `SyncStatusBanner` (notes list) shows offline, syncing, failed with
  Retry, or "N changes waiting to sync". `pendingChangesProvider` reads the
  queue (no separate counter). `SyncController` is started once by the app
  with `ref.listen`, so widget rebuilds never start a sync.
- **Scope**: notes only. Folders and tags are not synced as entities yet;
  their effect on notes (folder cleared, tag names) is.

## Cross-device sync (Phase 11)

```
Firestore users/{uid}/notes  --snapshots-->  NoteRemoteRepository.watchChanges
      ^                                             |
      | upsertUnlessNewer / deleteUnlessEdited      v
SyncRepositoryImpl (upload: queue)          SyncRepositoryImpl.followRemoteChanges
                                                    | applyRemoteNote / applyRemoteDelete
                                                    v   (never queued -> no loop)
                                            local database -> notesProvider -> UI
```

- **Versions**: `Note.version` (column `notes.version`, Firestore `version`;
  schema 4). 1 on create, +1 on every local change (also when a folder
  rename/delete or tag rename/delete changes the note). Notes received from
  the cloud keep the cloud's version, so the same number means the same
  revision everywhere.
- **Conflict rule** (`NoteVersioning`, domain): latest revision wins:
  higher version, else later `updatedAt` (two edits from the same revision),
  else a fixed content tie-break, so every device picks the same winner and
  all converge. Plus **edits win over deletes**:
  - update vs delete: an unsynced edit re-creates a note deleted elsewhere;
  - delete vs update: a cloud version newer than the deleted revision
    restores the note and drops the pending delete.
  - A local unsynced edit that loses is kept as a new note
    "<title> (conflict copy)", never silently dropped. The UI shows a
    one-off, non-blocking notice.
- **Uploads are conditional**: a Firestore transaction reads the cloud note
  and writes only if the local revision wins; otherwise the conflict is
  resolved locally.
- **Downloads**: the first snapshot lists every note (initial sync on a new
  device), later snapshots only changes. Each batch is applied in one local
  transaction, through the same local database the UI reads, so search,
  filters, sorting and counts update by themselves. Echoes of this device's
  own uploads compare equal and are ignored; duplicate events are no-ops.
- **Loop prevention**: cloud changes are written with `applyRemoteNote` /
  `applyRemoteDelete`, which never touch the sync queue; only user actions
  record outgoing changes.
- **Folders** travel inside note documents (`folderId` + `folderName`), so a
  device creates or renames the folder when a note needs it. Empty folders
  and tag colours stay local.
- **Lifecycle**: `remoteSyncProvider` holds exactly one Firestore listener for
  the signed-in user; Riverpod cancels it on sign-out or user change. It is
  kept alive by `SyncController` (started once by the app) and restarted
  after an error. Widgets never see Firestore.
- **Security rules** allow the new `version` and `folderName` fields.

## Settings (Phase 12)

```
SettingsScreen / notes sort sheet -> Settings (Notifier)      -> LoadSettings / SaveSettings
      ^                                     |                     -> SettingsRepository
      | select                              |                     -> preferences table
MaterialApp.themeMode <- themeModePreferenceProvider            (in the user's own database)
filteredNotesProvider <- noteQuery <- noteSortSettingProvider
```

- **What**: theme mode (system / light / dark) and the notes sort (the Phase 9
  `NoteSort`: edited / created / title, ascending / descending). Defaults:
  system theme, edited newest first.
- **Storage**: `preferences` key/value table (schema 5) in the signed-in
  user's database, so each account has its own settings on this device.
  Values are plain text (`dark`, `title`, `ascending`); unknown or malformed
  values load as the defaults. Settings are local only: not synced, never
  queued, work offline.
- **Lifecycle**: a synchronous `Notifier` (no loading state): signed out ->
  defaults (nothing stored); sign-in or app start -> the defaults at once,
  replaced by that user's saved settings when read (a change made before the
  read finishes wins); sign-out / another user -> rebuilt, so nothing carries
  over. Changes apply at once, then save; a failed save
  keeps the change for this run and the screen says it could not be saved.
- **One sort**: the Settings screen and the list's sort sheet both call
  `Settings.setNoteSort`; `noteQueryProvider` reads it through
  `noteSortSettingProvider` (no second sort state). Search, folder and tag
  filters stay temporary list state and are not persisted.
- **Rebuilds**: the app watches only the theme mode, the notes query only
  the sort.
- **Known limitation**: before sign-in (login screen) the theme follows the
  system; the user's theme applies once they are signed in.

## UI hardening (Phase 13)

The review checklist and fixes are in `docs/ux-review.md`. Conventions that
now apply to every screen:

- **Async states**: loading, data, empty (with a next step), filtered empty
  (different message), and error with a Retry that `ref.invalidate`s the
  provider. A failed refresh keeps showing the last good data.
- **Mutations**: the notifier ignores a new request while one is running
  (no double submit); screens show progress (button spinner or a thin bar)
  and a short confirmation ("Folder created", "Changes saved") or a failure
  message that says the data is safe. Side effects run in `ref.listen` or
  in the callback that started the action, never in `build`.
- **Editor**: leaving with changes offers Save / Discard / Stay; a failed
  save keeps the input.
- **Layout**: page content is limited to 760 px wide (`ContentWidth`);
  sheets and dialogs scroll; all screens are tested at 320 x 568 with 1.5x
  text in light and dark.
- **Keyboard**: scrolling dismisses it; fields use matching keyboard types
  and done/next actions.
- **Accessibility**: light-theme text actions use a darker gold (5.8:1 on
  cream; tested); small icon buttons have 40 px targets and tooltips;
  colours are named for screen readers and tags always show their names.

## Adding a feature

1. Create `features/<name>/{domain,data,presentation}` with the subfolders above.
2. Define entities, a repository contract and use cases in `domain`.
3. Add models, a data source interface and a repository implementation in `data`.
4. Build screens and Riverpod providers in `presentation`.
5. Run `flutter test`; the architecture test will flag wrong imports.

## Account deletion

```
DeleteAccountScreen -> DeleteAccountController -> DeleteAccount (use case)
   1. AuthRepository.reauthenticateWith{Password,Google}
   2. UserDataRepository.discardPendingSync   (sync_queue)
   3. UserDataRepository.deleteCloudData      (users/{uid}/notes, server only)
   4. UserDataRepository.deleteLocalData      (all tables of the user's DB)
   5. AuthRepository.deleteCurrentUser        (signs out -> login screen)
```

- Reached from Settings → Account → Delete account (`/settings/delete-account`).
  Required by Google Play for apps with account creation (plus a web link for
  deletion requests, outside the app).
- Order: identity first (also fails fast offline), uploads stopped before the
  cloud delete so nothing is re-uploaded, cloud before the account (the
  security rules need the signed-in owner). A failed step stops the rest and
  keeps the account, so the user can retry.
- Local rows are deleted rather than the database file, so it works the same
  on Android, iOS and the web.
- Email accounts confirm with their password, Google-only accounts with
  Google (`AppUser.signInMethods`). Needs a connection.
