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
│   ├── errors/                   sealed Failure, ExceptionMapper, guardFailures
│   ├── logging/app_logger.dart   AppLogger, ConsoleLogger, redaction
│   ├── usecase/usecase.dart      UseCase<Output, Input> base + NoParams
│   └── theme/app_theme.dart      Golden taupe light/dark themes
└── features/
    ├── auth/        (user, sign-out, auth state)
    ├── notes/       (note, local-first note storage; search/filter later)
    ├── folders/     (folders)
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

## Status of Phase 1 contracts

Structure, contracts and boundaries only. Nothing is functional yet:
- Repository implementations throw `UnimplementedError` and name the phase
  that will implement them.
- No Firebase, database, connectivity plugin or Riverpod dependency has been
  added; the `providers/`, `screens/`, `widgets/` and `state/` folders hold
  `.gitkeep` placeholders.
- Notes CRUD and authentication are not implemented.

## Adding a feature

1. Create `features/<name>/{domain,data,presentation}` with the subfolders above.
2. Define entities, a repository contract and use cases in `domain`.
3. Add models, a data source interface and a repository implementation in `data`.
4. Build screens and Riverpod providers in `presentation`.
5. Run `flutter test`; the architecture test will flag wrong imports.
