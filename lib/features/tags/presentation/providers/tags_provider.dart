import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../app/di/repository_providers.dart';
import '../../../../app/di/session_providers.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/tag.dart';
import '../../domain/usecases/observe_tags.dart';

part 'tags_provider.g.dart';

/// The signed-in user's tags (by name), live, including tags no note uses
/// any more (tags are independent). Used for tag suggestions. Empty while
/// signed out.
@riverpod
Stream<List<Tag>> tags(Ref ref) {
  final userId = ref.watch(
    currentUserIdProvider.select((session) => session.value),
  );
  if (userId == null) return Stream.value(const <Tag>[]);
  return ObserveTags(ref.watch(tagRepositoryProvider))(const NoParams());
}
