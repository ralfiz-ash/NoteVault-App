# NoteVault — Final Architecture Audit (Phase 15)

Date: 2026-11-17 · Branch: `feature/final-audit` · Baseline: `development` @ f686cbb

Scope: every requirement of the NoteVault specification
(`docs/04-flutter-riverpod-state-management.pdf`) and the project rules,
checked against the code, the tests and the app running on Android.

## Requirement compliance

| Area | Requirement | Status | Where |
|---|---|---|---|
| Auth | Email/password register + login | IMPLEMENTED | `features/auth` (use cases, `AuthController`) |
| Auth | Forgot password | IMPLEMENTED | `SendPasswordReset`, forgot-password screen |
| Auth | Google Sign-In (Android, iOS, Web) | IMPLEMENTED | `FirebaseAuthRemoteDataSource` |
| Auth | Logout; auth state via `StreamProvider` | IMPLEMENTED | `authStateProvider` (now through `ObserveAuthState`) |
| Auth | Friendly error messages | IMPLEMENTED | `AuthFailure` mapping |
| Notes | Create / read / edit / delete | IMPLEMENTED | `features/notes` use cases + controllers |
| Notes | Editor tracks unsaved changes, no silent discard | IMPLEMENTED | `NoteEditorScreen` (baseline + leave dialog) |
| Notes | Optimistic update + rollback | IMPLEMENTED | `DeleteNoteController`, update controller |
| Folders | CRUD, assign notes, counts derived from state | IMPLEMENTED | `features/folders`, `folderNoteCountsProvider` |
| Tags | Create/rename/delete, tag notes, colours | IMPLEMENTED | `features/tags` |
| Search | Title + content, 300 ms debounce, timer disposed | IMPLEMENTED | `NoteQuery`, `NoteSearchController` |
| Filter | By folder / tag / no folder, combinable | IMPLEMENTED | `filteredNotesProvider` |
| Sort | Edited / created / title, asc/desc | IMPLEMENTED | `NoteSort` |
| Family providers | `noteProvider(id)`, `folderNotesProvider(folderId)` | IMPLEMENTED | now drive the filtered list (fixed in audit) |
| Local DB | Drift SQLite, one database per user, migrations v1→v5 | IMPLEMENTED | `core/database` |
| Offline | Notes usable offline, changes retained | IMPLEMENTED | local-first repositories |
| Offline | Pending changes uploaded on reconnect | IMPLEMENTED | `sync_queue` outbox + `SyncController` |
| Offline | Connectivity state + offline banner | IMPLEMENTED | `connectionStatusProvider` (now through `ObserveConnectivity`) |
| Sync | Firestore `users/{uid}/notes`, cross-device updates | IMPLEMENTED | `SyncRepositoryImpl`, remote listener |
| Sync | Conflict strategy | IMPLEMENTED | `NoteVersioning` (version → updatedAt → tie-break; conflict copy kept) |
| Sync | No upload loop for remote changes | IMPLEMENTED | remote changes applied without queuing |
| Security | Owner-only Firestore rules | IMPLEMENTED | `firestore.rules` (deployed) |
| Settings | Theme mode + note sort, persisted per user | IMPLEMENTED | `Settings` (now a synchronous `Notifier`, fixed in audit) |
| UX | Loading / error / empty / data / retry everywhere | IMPLEMENTED | see `docs/ux-review.md` |
| Isolation | No data leaks between users | IMPLEMENTED | per-user DB, `user_isolation_test` |
| Tests | Unit, Riverpod (`ProviderContainer` + overrides), widget | IMPLEMENTED | 52 test files, 361 tests |

## Architecture and Riverpod

- Clean Architecture per feature (domain / data / presentation), composition
  root in `app/di`. Dependency rules are enforced by
  `test/architecture/dependency_rules_test.dart`.
- Riverpod 3 codegen throughout; `riverpod_lint` clean.
  `StreamProvider` for auth and connectivity, `Notifier` for settings and
  filters, `AsyncNotifier` for mutations, family providers for per-entity
  state, `select` to limit rebuilds, `autoDispose` by default and `keepAlive`
  only for the sync controller.
- Retries are limited to network failures (`providerRetry`).

## Strengths

- Local-first with a transactional outbox: a change and its sync entry are
  written in one transaction, so nothing is lost if the app is killed.
- Conditional transactional uploads protect newer cloud data; deletes never
  beat edits; a losing local edit is kept as a copy.
- A database per user keeps accounts fully isolated on shared devices.
- Strong test suite with fakes only (no real Firebase) and an architecture test.

## Issues found and fixed during the audit

| # | Issue | Impact | File | Fix |
|---|---|---|---|---|
| 1 | Family providers `folderNotesProvider` / `tagNotesProvider` existed but the list did not use them | Spec pattern not exercised; duplicated filtering | `notes_filter_provider.dart` | `filteredNotes` now builds on the matching family provider |
| 2 | `tagNotes` rebuilt on any tag change | Extra rebuilds | `tag_notes_provider.dart` | watches only the selected tag's name via `select` |
| 3 | `getNote` / `getNotes` providers were unused | Dead code | `note_use_case_providers.dart` | removed (use cases kept, still tested) |
| 4 | Auth state and connectivity providers called repositories directly | Bypassed the domain use cases | `auth_state_provider.dart`, `connection_status_provider.dart` | now go through `ObserveAuthState` / `ObserveConnectivity` |
| 5 | Settings was an `AsyncNotifier`; the spec asks for `NotifierProvider` | Spec deviation; brief loading spinner on Settings | `settings_provider.dart`, `settings_screen.dart` | synchronous `Notifier`: defaults at once, saved values replace them; late loads ignored via a generation check |
| 6 | `cupertino_icons` dependency unused | Unnecessary dependency | `pubspec.yaml` | removed |

## Remaining limitations (not fixed: would be new features)

- Folders without notes and tag colours are local only (notes carry their
  folder name and tags, so organisation still reaches other devices).
- Before sign-in the login screen follows the system theme.
- Firebase client API keys are in the public repository. They are
  identifiers, not secrets, but should be restricted in Google Cloud Console.
- Release / Play signing SHA fingerprints must be added in Firebase before a
  release build can use Google Sign-In.
- Phase 14 was not run as a separate phase; tests were written with each phase.

## Validation

- `dart run build_runner build`: OK
- `dart format .`: OK
- `flutter analyze`: no issues
- `flutter test`: 361 passed
- Android device (debug build): app starts signed in, notes list, drawer
  counts and folder filter (via the family provider) verified.

## Final status

**PASS.** All specification requirements are implemented and validated.
Ready to merge `development` into `main` after the release checklist above
(API key restrictions, release SHA fingerprints).
