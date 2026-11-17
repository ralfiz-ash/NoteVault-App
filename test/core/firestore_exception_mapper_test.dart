import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notevalult/core/errors/failure.dart';
import 'package:notevalult/core/firebase/firestore_exception_mapper.dart';

void main() {
  const mapper = FirestoreExceptionMapper();
  Failure map(String code) => mapper.map(
    FirebaseException(plugin: 'cloud_firestore', code: code),
    StackTrace.empty,
  );

  test('Firestore codes map to application failures', () {
    expect(map('unavailable'), isA<NetworkFailure>());
    expect(map('deadline-exceeded'), isA<NetworkFailure>());
    expect(map('unauthenticated'), isA<AuthFailure>());
    expect(map('permission-denied'), isA<RemoteFailure>());
    expect(map('not-found'), isA<NotFoundFailure>());
    expect(map('already-exists'), isA<RemoteFailure>());
    expect(map('internal'), isA<RemoteFailure>());
  });

  test('the raw FirebaseException is kept only as the cause', () {
    final error = FirebaseException(plugin: 'cloud_firestore', code: 'x');
    final failure = mapper.map(error, StackTrace.empty);
    expect(failure.cause, same(error));
    expect(failure.message, isNot(contains('cloud_firestore')));
  });

  test('non-Firebase errors become UnknownFailure', () {
    expect(
      mapper.map(StateError('x'), StackTrace.empty),
      isA<UnknownFailure>(),
    );
  });
}
