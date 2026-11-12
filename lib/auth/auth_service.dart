import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_starter_app/auth/auth_provider.dart';
import 'package:my_starter_app/auth/login_response.dart';
import 'package:my_starter_app/core/dio_provider.dart';

class AuthService {
  AuthService(this._dio, this._auth);

  final Dio _dio;
  final AuthNotifier _auth;

  Future<void> login({required String email, required String password}) async {
    final response = await _dio.post(
      'login',
      data: {'email': email, 'password': password},
    );
    final login = LoginResponse.fromJson(response.data);
    await _auth.signIn(token: login.token, user: login.user);
  }

  Future<void> logout() async {
    try {
      await _dio.post('auth/logout');
    } catch (_) {}
    await _auth.signOut();
  }
}

final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(
    ref.read(dioProvider),
    ref.read(authProvider.notifier),
  ),
);
