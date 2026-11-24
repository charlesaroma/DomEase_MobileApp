// ─── Validate Input Tests ─────────────────────────────────────────
import 'package:flutter_test/flutter_test.dart';

import 'package:domease/domain/use_cases/validate_input.dart';

void main() {
  test('email', () {
    expect(checkEmail('pearl@domease.app'), isNull);
    expect(checkEmail('pearl@domease'), isNotNull);
    expect(checkEmail(' '), isNotNull);
  });

  test('password needs 8 characters, a letter and a number', () {
    expect(checkPassword('short1'), isNotNull);
    expect(checkPassword('longenough'), isNotNull);
    expect(checkPassword('longenough1'), isNull);
  });

  test('phone numbers come out international, without the local 0', () {
    expect(normalisePhone('+256', '0772 123 456'), '+256772123456');
    expect(normalisePhone('+256', '772123456'), '+256772123456');
    expect(normalisePhone('+256', '123'), isNull);
    expect(prettyPhone('+256772123456'), '+256 772 123 456');
  });

  test('codes are six digits', () {
    expect(isCode('123456'), isTrue);
    expect(isCode('12345'), isFalse);
    expect(isCode('12a456'), isFalse);
  });
}
