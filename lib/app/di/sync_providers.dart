import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/sync/data/repositories/sync_repository_impl.dart';
import '../../features/sync/domain/repositories/sync_repository.dart';
import 'core_providers.dart';
import 'database_providers.dart';
import 'firebase_providers.dart';
import 'repository_providers.dart';

part 'sync_providers.g.dart';

/// One sync repository per signed-in user's database. keepAlive: it holds
/// the single-flight guard, so there must be exactly one instance.
@Riverpod(keepAlive: true)
SyncRepository syncRepository(Ref ref) => SyncRepositoryImpl(
  queue: ref.watch(syncQueueStoreProvider),
  localNotes: ref.watch(noteRepositoryProvider),
  remoteNotes: ref.watch(noteRemoteRepositoryProvider),
  logger: ref.watch(appLoggerProvider),
);
