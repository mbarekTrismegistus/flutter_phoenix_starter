import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_starter_app/auth/auth_provider.dart';
import 'package:my_starter_app/core/config.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(baseUrl: apiBaseUrl));

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await ref.read(tokenStorageProvider).getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (e, handler) async {
        if (e.response?.statusCode == 401) {
          await ref.read(authProvider.notifier).signOut();
        }
        return handler.next(e);
      },
    ),
  );

  return dio;
});
