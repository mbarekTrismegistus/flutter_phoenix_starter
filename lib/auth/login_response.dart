import 'dart:convert';

class LoginResponse {
  const LoginResponse({required this.token, this.user});

  final String token;
  final String? user;

  factory LoginResponse.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) {
      throw const FormatException('Login response must be a JSON object.');
    }

    final token = json['token'];
    if (token is! String || token.trim().isEmpty) {
      throw const FormatException(
        'Login response must include a non-empty token.',
      );
    }

    final userData = json['data'];
    if (userData != null && userData is! Map<String, dynamic>) {
      throw const FormatException(
        'Login response data must be a JSON object when provided.',
      );
    }

    return LoginResponse(
      token: token,
      user: userData == null ? null : jsonEncode(userData),
    );
  }
}
