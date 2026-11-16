import 'package:flutter_test/flutter_test.dart';
import 'package:notevalult/core/database/local_database_exception_mapper.dart';
import 'package:notevalult/core/errors/failure.dart';
import 'package:notevalult/features/folders/data/datasources/drift_folder_local_data_source.dart';
import 'package:notevalult/features/folders/data/repositories/folder_repository_impl.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/test_database.dart';

void main() {
  late FolderRepositoryImpl repository;

  setUp(() {
    repository = FolderRepositoryImpl(
      local: DriftFolderLocalDataSource(database: createTestDatabase()),
      exceptionMapper: const LocalDatabaseExceptionMapper(),
    );
  });

  test('create, read, list, update and delete', () async {
    final folder = buildFolder(name: 'Work');
    expect(await repository.createFolder(folder), folder);
    await repository.createFolder(buildFolder(id: 'f2', name: 'archive'));

    expect(await repository.getFolder('folder-1'), folder);
    expect(
      (await repository.getFolders()).map((f) => f.name),
      ['archive', 'Work'], // case-insensitive name order
    );

    final renamed = await repository.updateFolder(
      folder.copyWith(name: 'Projects'),
    );
    expect(renamed.name, 'Projects');
    expect(renamed.createdAt, folder.createdAt);

    await repository.deleteFolder('folder-1');
    await expectLater(
      repository.getFolder('folder-1'),
      throwsA(isA<NotFoundFailure>()),
    );
  });

  test('missing folders throw NotFoundFailure', () async {
    await expectLater(
      repository.updateFolder(buildFolder(id: 'nope')),
      throwsA(isA<NotFoundFailure>()),
    );
    await expectLater(
      repository.deleteFolder('nope'),
      throwsA(isA<NotFoundFailure>()),
    );
  });

  test('creating a duplicate id throws LocalDatabaseFailure', () async {
    await repository.createFolder(buildFolder());
    await expectLater(
      repository.createFolder(buildFolder()),
      throwsA(isA<LocalDatabaseFailure>()),
    );
  });
}
