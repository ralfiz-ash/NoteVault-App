import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/folders/data/datasources/drift_folder_local_data_source.dart';
import '../../features/folders/data/datasources/folder_local_data_source.dart';
import '../../features/folders/data/repositories/folder_repository_impl.dart';
import '../../features/folders/domain/repositories/folder_repository.dart';
import '../../features/notes/data/datasources/drift_note_local_data_source.dart';
import '../../features/notes/data/datasources/note_local_data_source.dart';
import '../../features/notes/data/repositories/note_repository_impl.dart';
import '../../features/notes/domain/repositories/note_repository.dart';
import '../../features/settings/data/datasources/drift_settings_local_data_source.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/tags/data/datasources/drift_tag_local_data_source.dart';
import '../../features/tags/data/datasources/tag_local_data_source.dart';
import '../../features/tags/data/repositories/tag_repository_impl.dart';
import '../../features/tags/domain/repositories/tag_repository.dart';
import 'core_providers.dart';
import 'database_providers.dart';

part 'repository_providers.g.dart';

/// Dependency chain:
///   appDatabase -> *LocalDataSource -> *Repository
///
/// Providers are typed with the abstraction (`NoteRepository`, not the
/// implementation), so tests can override any link with a fake.

@Riverpod(keepAlive: true)
NoteLocalDataSource noteLocalDataSource(Ref ref) => DriftNoteLocalDataSource(
  database: ref.watch(appDatabaseProvider),
  idGenerator: ref.watch(idGeneratorProvider),
);

@Riverpod(keepAlive: true)
NoteRepository noteRepository(Ref ref) => NoteRepositoryImpl(
  local: ref.watch(noteLocalDataSourceProvider),
  exceptionMapper: ref.watch(localDatabaseExceptionMapperProvider),
  clock: ref.watch(clockProvider),
  logger: ref.watch(appLoggerProvider),
  outbox: ref.watch(syncQueueStoreProvider),
  transactions: ref.watch(localTransactionsProvider),
);

@Riverpod(keepAlive: true)
FolderLocalDataSource folderLocalDataSource(Ref ref) =>
    DriftFolderLocalDataSource(database: ref.watch(appDatabaseProvider));

@Riverpod(keepAlive: true)
FolderRepository folderRepository(Ref ref) => FolderRepositoryImpl(
  local: ref.watch(folderLocalDataSourceProvider),
  exceptionMapper: ref.watch(localDatabaseExceptionMapperProvider),
  logger: ref.watch(appLoggerProvider),
  outbox: ref.watch(syncQueueStoreProvider),
  transactions: ref.watch(localTransactionsProvider),
);

@Riverpod(keepAlive: true)
TagLocalDataSource tagLocalDataSource(Ref ref) =>
    DriftTagLocalDataSource(database: ref.watch(appDatabaseProvider));

@Riverpod(keepAlive: true)
TagRepository tagRepository(Ref ref) => TagRepositoryImpl(
  local: ref.watch(tagLocalDataSourceProvider),
  exceptionMapper: ref.watch(localDatabaseExceptionMapperProvider),
  logger: ref.watch(appLoggerProvider),
  outbox: ref.watch(syncQueueStoreProvider),
  transactions: ref.watch(localTransactionsProvider),
);

/// The signed-in user's settings (in their own database, so each account
/// has its own settings).
@Riverpod(keepAlive: true)
SettingsRepository settingsRepository(Ref ref) => SettingsRepositoryImpl(
  local: DriftSettingsLocalDataSource(database: ref.watch(appDatabaseProvider)),
  exceptionMapper: ref.watch(localDatabaseExceptionMapperProvider),
  logger: ref.watch(appLoggerProvider),
);
