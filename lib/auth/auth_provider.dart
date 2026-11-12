import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_starter_app/storage/token_storage.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

sealed class AuthState {
  const AuthState();
}

class Authenticated extends AuthState {
  const Authenticated({required this.token, this.user});

  final String token;
  final String? user;
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class AuthNotifier extends AsyncNotifier<AuthState> {
  TokenStorage get _storage => ref.read(tokenStorageProvider);

  @override
  Future<AuthState> build() async {
    final token = await _storage.getToken();
    if (token == null) return const Unauthenticated();
    return Authenticated(token: token, user: await _storage.getUser());
  }

  Future<void> signIn({required String token, String? user}) async {
    await _storage.saveToken(token);
    if (user != null) await _storage.saveUser(user);
    state = AsyncData(Authenticated(token: token, user: user));
  }

  Future<void> signOut() async {
    await _storage.clear();
    state = const AsyncData(Unauthenticated());
  }
}

final authProvider =
    AsyncNotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
