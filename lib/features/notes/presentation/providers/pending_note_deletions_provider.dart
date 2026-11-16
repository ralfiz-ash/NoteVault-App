import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../app/di/session_providers.dart';

part 'pending_note_deletions_provider.g.dart';

/// Ids of notes being deleted right now. The list hides them at once
/// (optimistic delete) and shows them again if the delete fails (rollback).
/// Nothing else is copied: the notes themselves stay in [notesProvider].
///
/// keepAlive: a delete started from the note screen continues after that
/// screen closes. Cleared when the user changes.
@Riverpod(keepAlive: true)
class PendingNoteDeletions extends _$PendingNoteDeletions {
  @override
  Set<String> build() {
    ref.watch(currentUserIdProvider.select((session) => session.value));
    return const {};
  }

  void add(String id) => state = {...state, id};

  void remove(String id) => state = {...state}..remove(id);
}
