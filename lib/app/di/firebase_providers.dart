import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/analytics/app_analytics.dart';
import '../../core/errors/exception_mapper.dart';
import '../../core/firebase/firebase_app_analytics.dart';
import '../../core/firebase/firestore_exception_mapper.dart';
import '../../features/account/data/datasources/user_data_cloud_data_source.dart';
import '../../features/account/data/datasources/user_data_local_data_source.dart';
import '../../features/account/data/repositories/user_data_repository_impl.dart';
import '../../features/account/domain/repositories/user_data_repository.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/datasources/firebase_auth_remote_data_source.dart';
import '../../features/auth/data/datasources/google_id_token_source.dart';
import '../../features/auth/data/mappers/auth_exception_mapper.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/notes/data/datasources/firestore_note_remote_data_source.dart';
import '../../features/notes/data/datasources/note_remote_data_source.dart';
import '../../features/notes/data/repositories/note_remote_repository_impl.dart';
import '../../features/notes/domain/repositories/note_remote_repository.dart';
import 'core_providers.dart';
import 'database_providers.dart';

part 'firebase_providers.g.dart';

/// Firebase dependency chain:
///
///   FirebaseAuth + GoogleSignIn -> AuthRemoteDataSource -> AuthRepository
///   FirebaseFirestore -> NoteRemoteDataSource -> NoteRemoteRepository
///
/// The SDK singletons are only touched here, and only after `bootstrap()` has
/// initialised Firebase. Tests override any link with a fake.

// ---- SDK instances ---------------------------------------------------------

@Riverpod(keepAlive: true)
FirebaseAuth firebaseAuth(Ref ref) => FirebaseAuth.instance;

/// Product analytics (Firebase Analytics). Exposed as a provider only so that
/// presentation never imports Firebase and tests can swap in a fake; the
/// events are fire-and-forget side effects, never app state.
@Riverpod(keepAlive: true)
AppAnalytics appAnalytics(Ref ref) =>
    FirebaseAppAnalytics(ref.watch(appLoggerProvider));

@Riverpod(keepAlive: true)
FirebaseFirestore firebaseFirestore(Ref ref) => FirebaseFirestore.instance;

@Riverpod(keepAlive: true)
GoogleSignIn googleSignIn(Ref ref) => GoogleSignIn.instance;

// ---- Error mappers ---------------------------------------------------------

@Riverpod(keepAlive: true)
ExceptionMapper authExceptionMapper(Ref ref) => const AuthExceptionMapper();

@Riverpod(keepAlive: true)
ExceptionMapper firestoreExceptionMapper(Ref ref) =>
    const FirestoreExceptionMapper();

// ---- Authentication --------------------------------------------------------

@Riverpod(keepAlive: true)
GoogleIdTokenSource googleIdTokenSource(Ref ref) =>
    GoogleSignInIdTokenSource(ref.watch(googleSignInProvider));

@Riverpod(keepAlive: true)
AuthRemoteDataSource authRemoteDataSource(Ref ref) =>
    FirebaseAuthRemoteDataSource(
      auth: ref.watch(firebaseAuthProvider),
      googleIdTokens: ref.watch(googleIdTokenSourceProvider),
      useWebPopupForGoogle: kIsWeb,
    );

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) => AuthRepositoryImpl(
  remote: ref.watch(authRemoteDataSourceProvider),
  exceptionMapper: ref.watch(authExceptionMapperProvider),
  logger: ref.watch(appLoggerProvider),
);

// ---- Remote notes (Firestore) ----------------------------------------------

@Riverpod(keepAlive: true)
NoteRemoteDataSource noteRemoteDataSource(Ref ref) =>
    FirestoreNoteRemoteDataSource(
      firestore: ref.watch(firebaseFirestoreProvider),
    );

@Riverpod(keepAlive: true)
NoteRemoteRepository noteRemoteRepository(Ref ref) => NoteRemoteRepositoryImpl(
  remote: ref.watch(noteRemoteDataSourceProvider),
  exceptionMapper: ref.watch(firestoreExceptionMapperProvider),
  logger: ref.watch(appLoggerProvider),
);

// ---- Account data (for account deletion) ----------------------------------

/// Removes the signed-in user's data in Firestore and in their own local
/// database. Rebuilt with the database when the user changes.
@Riverpod(keepAlive: true)
UserDataRepository userDataRepository(Ref ref) => UserDataRepositoryImpl(
  cloud: FirestoreUserDataCloudDataSource(
    firestore: ref.watch(firebaseFirestoreProvider),
  ),
  local: DriftUserDataLocalDataSource(database: ref.watch(appDatabaseProvider)),
  cloudExceptionMapper: ref.watch(firestoreExceptionMapperProvider),
  localExceptionMapper: ref.watch(localDatabaseExceptionMapperProvider),
  logger: ref.watch(appLoggerProvider),
);
