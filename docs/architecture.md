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
| any feature | - | `app/` |

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

## Adding a feature

1. Create `features/<name>/{domain,data,presentation}` with the subfolders above.
2. Define entities, a repository contract and use cases in `domain`.
3. Add models, a data source interface and a repository implementation in `data`.
4. Build screens and Riverpod providers in `presentation`.
5. Run `flutter test`; the architecture test will flag wrong imports.
