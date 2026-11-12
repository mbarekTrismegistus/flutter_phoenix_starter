import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:__PROJECT_NAME__/auth/auth_provider.dart';
import 'package:__PROJECT_NAME__/screens/home_screen.dart';
import 'package:__PROJECT_NAME__/screens/login_screen.dart';
import 'package:__PROJECT_NAME__/screens/placeholders.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(authProvider, (_, __) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final auth = authState.value;
      final location = state.matchedLocation;

      // Auth still loading: wait on the splash screen.
      if (authState.isLoading) {
        return location == '/splash' ? null : '/splash';
      }

      // If secure storage fails during startup, allow recovery through login.
      if (authState.hasError || auth is! Authenticated) {
        return location == '/login' ? null : '/login';
      }

      // Authenticated: keep them out of splash/login.
      if (location == '/login' || location == '/splash') return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
    ],
  );
});
