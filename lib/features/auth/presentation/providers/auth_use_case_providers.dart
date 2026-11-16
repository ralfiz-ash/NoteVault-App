import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../app/di/firebase_providers.dart';
import '../../domain/usecases/register_with_email.dart';
import '../../domain/usecases/send_password_reset.dart';
import '../../domain/usecases/sign_in_with_email.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_out.dart';

part 'auth_use_case_providers.g.dart';

/// Authentication use cases, built on the injected [AuthRepository]. They are
/// stateless, so they are simply auto-disposed when unused.

@riverpod
SignInWithEmail signInWithEmail(Ref ref) =>
    SignInWithEmail(ref.watch(authRepositoryProvider));

@riverpod
RegisterWithEmail registerWithEmail(Ref ref) =>
    RegisterWithEmail(ref.watch(authRepositoryProvider));

@riverpod
SignInWithGoogle signInWithGoogle(Ref ref) =>
    SignInWithGoogle(ref.watch(authRepositoryProvider));

@riverpod
SendPasswordReset sendPasswordReset(Ref ref) =>
    SendPasswordReset(ref.watch(authRepositoryProvider));

@riverpod
SignOut signOut(Ref ref) => SignOut(ref.watch(authRepositoryProvider));
