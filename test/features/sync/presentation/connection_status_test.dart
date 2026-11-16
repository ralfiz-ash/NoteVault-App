import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notevalult/app/di/connectivity_providers.dart';
import 'package:notevalult/features/sync/data/datasources/connectivity_plus_data_source.dart';
import 'package:notevalult/features/sync/domain/entities/connectivity_status.dart';
import 'package:notevalult/features/sync/presentation/providers/connection_status_provider.dart';

import '../../../helpers/fake_repositories.dart';
import '../../../helpers/test_helpers.dart';

class _FakeConnectivity extends Fake implements Connectivity {
  _FakeConnectivity(this.initial);

  final List<ConnectivityResult> initial;
  final changes = StreamController<List<ConnectivityResult>>.broadcast();

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => initial;

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged => changes.stream;
}

void main() {
  group('platform result -> ConnectivityStatus', () {
    test('any interface means connected; none means disconnected', () {
      expect(
        ConnectivityPlusDataSource.toStatus([ConnectivityResult.wifi]),
        ConnectivityStatus.connected,
      );
      expect(
        ConnectivityPlusDataSource.toStatus([
          ConnectivityResult.none,
          ConnectivityResult.mobile,
        ]),
        ConnectivityStatus.connected,
      );
      expect(
        ConnectivityPlusDataSource.toStatus([ConnectivityResult.none]),
        ConnectivityStatus.disconnected,
      );
      expect(
        ConnectivityPlusDataSource.toStatus([]),
        ConnectivityStatus.unknown,
      );
    });
  });

  test('provider represents connected, disconnected and unknown', () async {
    final repo = FakeConnectivityRepository();
    final container = createContainer(
      overrides: [connectivityRepositoryProvider.overrideWithValue(repo)],
    );
    final seen = <AsyncValue<ConnectivityStatus>>[];
    container.listen(
      connectionStatusProvider,
      (_, next) => seen.add(next),
      fireImmediately: true,
    );
    expect(seen.single.isLoading, isTrue);

    for (final status in ConnectivityStatus.values) {
      repo.emit(status);
      await pumpEventQueue();
      expect(container.read(connectionStatusProvider).value, status);
    }
  });

  test('real chain: initial status then changes, duplicates dropped', () async {
    final platform = _FakeConnectivity([ConnectivityResult.wifi]);
    final container = createContainer(
      overrides: [connectivityProvider.overrideWithValue(platform)],
    );
    final values = <ConnectivityStatus>[];
    container.listen(connectionStatusProvider, (_, next) {
      if (next case AsyncData(:final value)) values.add(value);
    });
    await pumpEventQueue();

    platform.changes.add([ConnectivityResult.mobile]); // still connected
    platform.changes.add([ConnectivityResult.none]);
    await pumpEventQueue();

    expect(values, [
      ConnectivityStatus.connected,
      ConnectivityStatus.disconnected,
    ]);
  });
}
