import 'package:flutter_test/flutter_test.dart';
import 'package:notevalult/features/auth/domain/validation/auth_validators.dart';

void main() {
  test('email', () {
    expect(AuthValidators.email(''), 'Email is required');
    expect(AuthValidators.email('   '), 'Email is required');
    expect(AuthValidators.email('nope'), 'Enter a valid email address');
    expect(AuthValidators.email('a@b'), 'Enter a valid email address');
    expect(AuthValidators.email(' me@example.com '), isNull);
  });

  test('login password only needs a value', () {
    expect(AuthValidators.loginPassword(''), 'Password is required');
    expect(AuthValidators.loginPassword('x'), isNull);
  });

  test('new password needs the minimum length', () {
    expect(AuthValidators.newPassword(''), 'Password is required');
    expect(
      AuthValidators.newPassword('1234567'),
      'Password must be at least 8 characters',
    );
    expect(AuthValidators.newPassword('12345678'), isNull);
  });

  test('confirm password must match', () {
    expect(
      AuthValidators.confirmPassword('', 'pw'),
      'Please confirm your password',
    );
    expect(
      AuthValidators.confirmPassword('pw2', 'pw'),
      'Passwords do not match',
    );
    expect(AuthValidators.confirmPassword('pw', 'pw'), isNull);
  });
}
