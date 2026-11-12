import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  TokenStorage([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  static const _tokenKey = 'auth_token';
  static const _userData = 'user_data';

  final FlutterSecureStorage _storage;

  Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  Future<String?> getToken() => _storage.read(key: _tokenKey);

  Future<void> deleteToken() => _storage.delete(key: _tokenKey);

  Future<void> saveUser(String user) =>
      _storage.write(key: _userData, value: user);

  Future<String?> getUser() => _storage.read(key: _userData);

  Future<void> deleteUser() => _storage.delete(key: _userData);

  /// Call on logout.
  Future<void> clear() async {
    await deleteToken();
    await deleteUser();
  }
}
