import 'dart:async';

import 'package:notevalult/core/errors/failure.dart';
import 'package:notevalult/features/auth/domain/entities/app_user.dart';
import 'package:notevalult/features/auth/domain/repositories/auth_repository.dart';
import 'package:notevalult/features/folders/domain/entities/folder.dart';
import 'package:notevalult/features/folders/domain/repositories/folder_repository.dart';
import 'package:notevalult/features/tags/domain/entities/tag.dart';
import 'package:notevalult/features/tags/domain/repositories/tag_repository.dart';
import 'package:notevalult/features/notes/domain/entities/note.dart';
import 'package:notevalult/features/notes/domain/repositories/note_repository.dart';
import 'package:notevalult/features/sync/domain/entities/connectivity_status.dart';
import 'package:notevalult/features/sync/domain/repositories/connectivity_repository.dart';

/// Auth repository driven by the test: call [emit] to change the session.
/// Like Firebase, a new subscriber first gets the current session (once one
/// has been emitted), then every change.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository();

  /// Starts with a restored session for [user].
  FakeAuthRepository.signedIn(AppUser user) : _current = user, _known = true;

  final _controller = StreamController<AppUser?>.broadcast();
  AppUser? _current;
  bool _known = false;

  void emit(AppUser? user) {
    _current = user;
    _known = true;
    _controller.add(user);
  }

  void emitError(Object error) => _controller.addError(error);

  /// The user the next successful sign-in / registration returns.
  AppUser nextUser = const AppUser(uid: 'u1', email: 'a@b.c');

  /// If set, the next call throws it.
  Object? nextError;

  /// If set, the next call waits for it (to observe loading states).
  Completer<void>? gate;

  /// Calls made, without passwords.
  final calls = <String>[];

  Future<void> _step(String call) async {
    calls.add(call);
    final wait = gate;
    if (wait != null) {
      gate = null;
      await wait.future;
    }
    final error = nextError;
    if (error != null) {
      nextError = null;
      throw error;
    }
  }

  Future<AppUser> _signIn(String call) async {
    await _step(call);
    emit(nextUser);
    return nextUser;
  }

  @override
  AppUser? get currentUser => _current;

  @override
  Stream<AppUser?> authStateChanges() async* {
    if (_known) yield _current;
    yield* _controller.stream;
  }

  @override
  Future<AppUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) => _signIn('signIn:$email');

  @override
  Future<AppUser> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) => _signIn('register:$email');

  @override
  Future<AppUser> signInWithGoogle() => _signIn('google');

  @override
  Future<void> sendPasswordResetEmail(String email) => _step('reset:$email');

  @override
  Future<void> signOut() async {
    await _step('signOut');
    emit(null);
  }
}

/// In-memory [NoteRepository] with the same semantics as the real one
/// (NotFoundFailure, createdAt kept on update). [watchNotes] replays the
/// current list to each new listener, like the database watch.
class FakeNoteRepository implements NoteRepository {
  FakeNoteRepository({List<Note> initial = const [], this.clock});

  final DateTime Function()? clock;
  final Map<String, Note> _notes = {};
  final _changes = StreamController<void>.broadcast();

  /// If set, the next mutation throws it.
  Failure? nextMutationError;

  /// If set, the next mutation waits for it (to observe loading states).
  Completer<void>? gate;

  /// If > 0, that many [watchNotes] subscriptions fail immediately.
  int failingWatches = 0;

  final calls = <String>[];

  List<Note> get _sorted =>
      _notes.values.toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  void seed(List<Note> notes) {
    for (final n in notes) {
      _notes[n.id] = n;
    }
    _changes.add(null);
  }

  Future<void> _wait() async {
    final wait = gate;
    if (wait != null) {
      gate = null;
      await wait.future;
    }
  }

  void _throwIfQueued() {
    final error = nextMutationError;
    if (error != null) {
      nextMutationError = null;
      throw error;
    }
  }

  @override
  Stream<List<Note>> watchNotes() async* {
    if (failingWatches > 0) {
      failingWatches--;
      throw const LocalDatabaseFailure();
    }
    yield _sorted;
    yield* _changes.stream.map((_) => _sorted);
  }

  @override
  Future<List<Note>> getNotes() async => _sorted;

  @override
  Future<Note> getNote(String id) async =>
      _notes[id] ?? (throw NotFoundFailure(cause: id));

  @override
  Future<Note> createNote(Note note) async {
    calls.add('create:${note.id}');
    await _wait();
    _throwIfQueued();
    _notes[note.id] = note;
    _changes.add(null);
    return note;
  }

  @override
  Future<Note> updateNote(Note note) async {
    calls.add('update:${note.id}');
    await _wait();
    _throwIfQueued();
    final existing = _notes[note.id] ?? (throw NotFoundFailure(cause: note.id));
    final saved = Note(
      id: note.id,
      title: note.title,
      content: note.content,
      folderId: note.folderId,
      tags: note.tags,
      createdAt: existing.createdAt,
      updatedAt: clock?.call() ?? note.updatedAt,
    );
    _notes[note.id] = saved;
    _changes.add(null);
    return saved;
  }

  @override
  Future<void> deleteNote(String id) async {
    calls.add('delete:$id');
    await _wait();
    _throwIfQueued();
    if (_notes.remove(id) == null) throw NotFoundFailure(cause: id);
    _changes.add(null);
  }
}

/// Like the real one, a new subscriber first gets the current status.
class FakeConnectivityRepository implements ConnectivityRepository {
  final _controller = StreamController<ConnectivityStatus>.broadcast();
  ConnectivityStatus? _current;

  void emit(ConnectivityStatus status) {
    _current = status;
    _controller.add(status);
  }

  @override
  Stream<ConnectivityStatus> watchStatus() async* {
    final current = _current;
    if (current != null) yield current;
    yield* _controller.stream;
  }
}

/// In-memory folders, replaying the current list to new listeners.
class FakeFolderRepository implements FolderRepository {
  FakeFolderRepository([List<Folder> initial = const []]) {
    for (final f in initial) {
      _folders[f.id] = f;
    }
  }

  final Map<String, Folder> _folders = {};
  final _changes = StreamController<void>.broadcast();

  List<Folder> get _sorted =>
      _folders.values.toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

  @override
  Stream<List<Folder>> watchFolders() async* {
    yield _sorted;
    yield* _changes.stream.map((_) => _sorted);
  }

  @override
  Future<List<Folder>> getFolders() async => _sorted;

  @override
  Future<Folder> getFolder(String id) async =>
      _folders[id] ?? (throw NotFoundFailure(cause: id));

  @override
  Future<Folder> createFolder(Folder folder) async {
    _folders[folder.id] = folder;
    _changes.add(null);
    return folder;
  }

  @override
  Future<Folder> updateFolder(Folder folder) => createFolder(folder);

  @override
  Future<void> deleteFolder(String id) async {
    _folders.remove(id);
    _changes.add(null);
  }
}

class FakeTagRepository implements TagRepository {
  FakeTagRepository([this._tags = const []]);

  final List<Tag> _tags;

  @override
  Stream<List<Tag>> watchTags() => Stream.value(_tags);

  @override
  Future<List<Tag>> getTags() async => _tags;

  @override
  Future<void> deleteTag(String id) async {}
}
