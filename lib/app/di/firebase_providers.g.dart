// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firebase_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Firebase dependency chain:
///
///   FirebaseAuth + GoogleSignIn -> AuthRemoteDataSource -> AuthRepository
///   FirebaseFirestore -> NoteRemoteDataSource -> NoteRemoteRepository
///
/// The SDK singletons are only touched here, and only after `bootstrap()` has
/// initialised Firebase. Tests override any link with a fake.
// ---- SDK instances ---------------------------------------------------------

@ProviderFor(firebaseAuth)
final firebaseAuthProvider = FirebaseAuthProvider._();

/// Firebase dependency chain:
///
///   FirebaseAuth + GoogleSignIn -> AuthRemoteDataSource -> AuthRepository
///   FirebaseFirestore -> NoteRemoteDataSource -> NoteRemoteRepository
///
/// The SDK singletons are only touched here, and only after `bootstrap()` has
/// initialised Firebase. Tests override any link with a fake.
// ---- SDK instances ---------------------------------------------------------

final class FirebaseAuthProvider
    extends $FunctionalProvider<FirebaseAuth, FirebaseAuth, FirebaseAuth>
    with $Provider<FirebaseAuth> {
  /// Firebase dependency chain:
  ///
  ///   FirebaseAuth + GoogleSignIn -> AuthRemoteDataSource -> AuthRepository
  ///   FirebaseFirestore -> NoteRemoteDataSource -> NoteRemoteRepository
  ///
  /// The SDK singletons are only touched here, and only after `bootstrap()` has
  /// initialised Firebase. Tests override any link with a fake.
  // ---- SDK instances ---------------------------------------------------------
  FirebaseAuthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'firebaseAuthProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$firebaseAuthHash();

  @$internal
  @override
  $ProviderElement<FirebaseAuth> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FirebaseAuth create(Ref ref) {
    return firebaseAuth(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FirebaseAuth value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FirebaseAuth>(value),
    );
  }
}

String _$firebaseAuthHash() => r'8c3e9d11b27110ca96130356b5ef4d5d34a5ffc2';

@ProviderFor(firebaseFirestore)
final firebaseFirestoreProvider = FirebaseFirestoreProvider._();

final class FirebaseFirestoreProvider
    extends
        $FunctionalProvider<
          FirebaseFirestore,
          FirebaseFirestore,
          FirebaseFirestore
        >
    with $Provider<FirebaseFirestore> {
  FirebaseFirestoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'firebaseFirestoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$firebaseFirestoreHash();

  @$internal
  @override
  $ProviderElement<FirebaseFirestore> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FirebaseFirestore create(Ref ref) {
    return firebaseFirestore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FirebaseFirestore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FirebaseFirestore>(value),
    );
  }
}

String _$firebaseFirestoreHash() => r'211c9d7cd91051da8adfacbf85a09b8bad1d41e8';

@ProviderFor(googleSignIn)
final googleSignInProvider = GoogleSignInProvider._();

final class GoogleSignInProvider
    extends $FunctionalProvider<GoogleSignIn, GoogleSignIn, GoogleSignIn>
    with $Provider<GoogleSignIn> {
  GoogleSignInProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'googleSignInProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$googleSignInHash();

  @$internal
  @override
  $ProviderElement<GoogleSignIn> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoogleSignIn create(Ref ref) {
    return googleSignIn(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoogleSignIn value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoogleSignIn>(value),
    );
  }
}

String _$googleSignInHash() => r'be6e657edfb1790d127cff1d3820a50c34e65011';

@ProviderFor(authExceptionMapper)
final authExceptionMapperProvider = AuthExceptionMapperProvider._();

final class AuthExceptionMapperProvider
    extends
        $FunctionalProvider<ExceptionMapper, ExceptionMapper, ExceptionMapper>
    with $Provider<ExceptionMapper> {
  AuthExceptionMapperProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authExceptionMapperProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authExceptionMapperHash();

  @$internal
  @override
  $ProviderElement<ExceptionMapper> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ExceptionMapper create(Ref ref) {
    return authExceptionMapper(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExceptionMapper value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExceptionMapper>(value),
    );
  }
}

String _$authExceptionMapperHash() =>
    r'0e10a355d1be550e5ddbbf2fa83abf423e810f90';

@ProviderFor(firestoreExceptionMapper)
final firestoreExceptionMapperProvider = FirestoreExceptionMapperProvider._();

final class FirestoreExceptionMapperProvider
    extends
        $FunctionalProvider<ExceptionMapper, ExceptionMapper, ExceptionMapper>
    with $Provider<ExceptionMapper> {
  FirestoreExceptionMapperProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'firestoreExceptionMapperProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$firestoreExceptionMapperHash();

  @$internal
  @override
  $ProviderElement<ExceptionMapper> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ExceptionMapper create(Ref ref) {
    return firestoreExceptionMapper(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExceptionMapper value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExceptionMapper>(value),
    );
  }
}

String _$firestoreExceptionMapperHash() =>
    r'94e051bc6c53d4b0e8d8a9bcfca1df5b19c7d8d7';

@ProviderFor(googleIdTokenSource)
final googleIdTokenSourceProvider = GoogleIdTokenSourceProvider._();

final class GoogleIdTokenSourceProvider
    extends
        $FunctionalProvider<
          GoogleIdTokenSource,
          GoogleIdTokenSource,
          GoogleIdTokenSource
        >
    with $Provider<GoogleIdTokenSource> {
  GoogleIdTokenSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'googleIdTokenSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$googleIdTokenSourceHash();

  @$internal
  @override
  $ProviderElement<GoogleIdTokenSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GoogleIdTokenSource create(Ref ref) {
    return googleIdTokenSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoogleIdTokenSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoogleIdTokenSource>(value),
    );
  }
}

String _$googleIdTokenSourceHash() =>
    r'a17e26bd139060168a109b786bf1b0e4c88d0097';

@ProviderFor(authRemoteDataSource)
final authRemoteDataSourceProvider = AuthRemoteDataSourceProvider._();

final class AuthRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          AuthRemoteDataSource,
          AuthRemoteDataSource,
          AuthRemoteDataSource
        >
    with $Provider<AuthRemoteDataSource> {
  AuthRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRemoteDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<AuthRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AuthRemoteDataSource create(Ref ref) {
    return authRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRemoteDataSource>(value),
    );
  }
}

String _$authRemoteDataSourceHash() =>
    r'ac47d6851b6fdd7e855ba532e630de267572fdf3';

@ProviderFor(authRepository)
final authRepositoryProvider = AuthRepositoryProvider._();

final class AuthRepositoryProvider
    extends $FunctionalProvider<AuthRepository, AuthRepository, AuthRepository>
    with $Provider<AuthRepository> {
  AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'2a26e59caf751da8035f81228b0ca8846947c97d';

@ProviderFor(noteRemoteDataSource)
final noteRemoteDataSourceProvider = NoteRemoteDataSourceProvider._();

final class NoteRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          NoteRemoteDataSource,
          NoteRemoteDataSource,
          NoteRemoteDataSource
        >
    with $Provider<NoteRemoteDataSource> {
  NoteRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'noteRemoteDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$noteRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<NoteRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NoteRemoteDataSource create(Ref ref) {
    return noteRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NoteRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NoteRemoteDataSource>(value),
    );
  }
}

String _$noteRemoteDataSourceHash() =>
    r'549df363d1f9924723deb0e54ef68d63fc7fa2f7';

@ProviderFor(noteRemoteRepository)
final noteRemoteRepositoryProvider = NoteRemoteRepositoryProvider._();

final class NoteRemoteRepositoryProvider
    extends
        $FunctionalProvider<
          NoteRemoteRepository,
          NoteRemoteRepository,
          NoteRemoteRepository
        >
    with $Provider<NoteRemoteRepository> {
  NoteRemoteRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'noteRemoteRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$noteRemoteRepositoryHash();

  @$internal
  @override
  $ProviderElement<NoteRemoteRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NoteRemoteRepository create(Ref ref) {
    return noteRemoteRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NoteRemoteRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NoteRemoteRepository>(value),
    );
  }
}

String _$noteRemoteRepositoryHash() =>
    r'4db47865a95cd60a6dc86eb7261f7df7c514381e';
