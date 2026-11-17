import 'package:flutter_test/flutter_test.dart';
import 'package:notevalult/core/database/sync_queue_store.dart';

import '../helpers/fixtures.dart';
import '../helpers/test_database.dart';

void main() {
  late SyncQueueStore store;
  setUp(() => store = SyncQueueStore(createTestDatabase(), () => fixedNow));

  Future<SyncQueueEntry?> row(String id) async =>
      (await store.all()).where((e) => e.entityId == id).firstOrNull;

  Future<void> record(String id, SyncOperation op) =>
      store.record(SyncEntity.note, id, op);

  group('coalescing', () {
    test(
      'create + update + update -> one create with the latest version',
      () async {
        await record('n', SyncOperation.create);
        await record('n', SyncOperation.update);
        await record('n', SyncOperation.update);

        final e = (await store.all()).single;
        expect(e.operation, SyncOperation.create);
        expect(e.version, 3);
        expect(e.status, SyncItemStatus.pending);
      },
    );

    test('update + update -> update', () async {
      await record('n', SyncOperation.update);
      await record('n', SyncOperation.update);
      expect((await row('n'))!.operation, SyncOperation.update);
    });

    test(
      'create + delete before any upload attempt -> nothing to sync',
      () async {
        await record('n', SyncOperation.create);
        await record('n', SyncOperation.delete);
        expect(await store.all(), isEmpty);
      },
    );

    test(
      'create + delete after an attempt -> delete (cloud may have it)',
      () async {
        await record('n', SyncOperation.create);
        final e = (await store.due()).single;
        await store.claim(e);
        await store.fail(e, 'offline');

        await record('n', SyncOperation.delete);
        expect((await row('n'))!.operation, SyncOperation.delete);
      },
    );

    test('update + delete -> delete; delete + update -> update', () async {
      await record('a', SyncOperation.update);
      await record('a', SyncOperation.delete);
      expect((await row('a'))!.operation, SyncOperation.delete);

      await record('a', SyncOperation.update);
      expect((await row('a'))!.operation, SyncOperation.update);
    });
  });

  group('processing guards', () {
    test(
      'an item can only be claimed once, and not with a stale version',
      () async {
        await record('n', SyncOperation.create);
        final e = (await store.due()).single;

        expect(await store.claim(e), isTrue);
        expect(await store.claim(e), isFalse); // already syncing
        expect(await store.due(), isEmpty); // syncing items are not due

        await record('n', SyncOperation.update); // newer local change
        final stale = SyncQueueEntry(
          entityType: e.entityType,
          entityId: e.entityId,
          operation: e.operation,
          status: SyncItemStatus.pending,
          version: e.version,
          retryCount: 0,
        );
        expect(await store.claim(stale), isFalse);
      },
    );

    test('complete removes the row', () async {
      await record('n', SyncOperation.create);
      final e = (await store.due()).single;
      await store.claim(e);
      await store.complete(e);
      expect(await store.all(), isEmpty);
    });

    test('a change during the upload keeps the row pending', () async {
      await record('n', SyncOperation.create);
      final e = (await store.due()).single;
      await store.claim(e);

      await record('n', SyncOperation.update); // edited while uploading
      await store.complete(e);

      final left = (await row('n'))!;
      expect(left.status, SyncItemStatus.pending);
      expect(left.version, e.version + 1);
    });

    test('fail keeps the row with retry count and error', () async {
      await record('n', SyncOperation.create);
      final e = (await store.due()).single;
      await store.claim(e);
      await store.fail(e, 'No network');

      final left = (await row('n'))!;
      expect(left.status, SyncItemStatus.failed);
      expect(left.retryCount, 1);
      expect(left.lastError, 'No network');
      expect(await store.due(), hasLength(1)); // retried next time
    });

    test('interrupted syncs (app killed) become pending again', () async {
      await record('n', SyncOperation.create);
      await store.claim((await store.due()).single);
      expect(await store.due(), isEmpty);

      await store.releaseInterrupted();
      expect(await store.due(), hasLength(1));
    });
  });

  test('counts come from the queue', () async {
    final counts = <int>[];
    final sub = store.watchCounts().listen((c) => counts.add(c.pending));
    addTearDown(sub.cancel);
    await pumpEventQueue();

    await record('a', SyncOperation.create);
    await record('b', SyncOperation.create);
    await record('a', SyncOperation.update); // merged, still 2
    await pumpEventQueue();

    expect(counts.first, 0);
    expect(counts.last, 2);
  });
}
