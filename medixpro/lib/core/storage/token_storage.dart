import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  final FlutterSecureStorage _storage;
  const TokenStorage(this._storage);

  static const _accessKey = "access_token";
  static const _refreshKey = "refresh_token";
  static const _roleKey = "user_role";
  static const _usernameKey = "username";
  static const _emailKey = "email";

  Future<void> saveTokens(
    String access,
    String refresh, {
    required String role,
  }) async {
    await Future.wait([
      _storage.write(key: _accessKey, value: access),
      _storage.write(key: _refreshKey, value: refresh),
      _storage.write(key: _roleKey, value: role),
    ]);
  }

  Future<void> saveAccessToken(String access) async {
    await _storage.write(key: _accessKey, value: access);
  }

  Future<void> saveUserInfo(String username, String email) async {
    await Future.wait([
      _storage.write(key: _usernameKey, value: username),
      _storage.write(key: _emailKey, value: email),
    ]);
  }

  Future<String?> getAccessToken() => _storage.read(key: _accessKey);
  Future<String?> getRefreshToken() => _storage.read(key: _refreshKey);
  Future<String?> getRole() => _storage.read(key: _roleKey);
  Future<String?> getUsername() => _storage.read(key: _usernameKey);
  Future<String?> getEmail() => _storage.read(key: _emailKey);

  Future<bool> hasToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> clear() async => _storage.deleteAll();
}