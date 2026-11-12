import 'package:flutter_test/flutter_test.dart';
import 'package:my_starter_app/auth/login_response.dart';

void main() {
  group('LoginResponse.fromJson', () {
    test('reads a token and encodes the optional user data', () {
      final response = LoginResponse.fromJson({
        'token': 'abc123',
        'data': {'email': 'user@example.com'},
      });

      expect(response.token, 'abc123');
      expect(response.user, '{"email":"user@example.com"}');
    });

    test('accepts a token without user data', () {
      final response = LoginResponse.fromJson({'token': 'abc123'});

      expect(response.token, 'abc123');
      expect(response.user, isNull);
    });

    test('rejects a response without a valid token', () {
      expect(
        () => LoginResponse.fromJson({'token': ''}),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects non-object user data', () {
      expect(
        () => LoginResponse.fromJson({'token': 'abc123', 'data': []}),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects a non-object response', () {
      expect(
        () => LoginResponse.fromJson('not an object'),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
