import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  final FlutterSecureStorage _storage;

  const TokenStorage(this._storage);

  static const _kAccess   = "access_token";
  static const _kRefresh  = "refresh_token";
  static const _kRole     = "user_role";
  static const _kUsername = "username";
  static const _kEmail    = "email";

  // ✅ sequential writes — يحل مشكلة race condition على Android
  Future<void> saveTokens(
    String access,
    String refresh, {
    required String role,
  }) async {
    await _storage.write(key: _kAccess,  value: access);
    await _storage.write(key: _kRefresh, value: refresh);
    await _storage.write(key: _kRole,    value: role);
  }

  Future<void> saveAccessToken(String access) async =>
      _storage.write(key: _kAccess, value: access);

  Future<void> saveUserInfo(String username, String email) async {
    await _storage.write(key: _kUsername, value: username);
    await _storage.write(key: _kEmail,    value: email);
  }

  Future<String?> getAccessToken()  => _storage.read(key: _kAccess);
  Future<String?> getRefreshToken() => _storage.read(key: _kRefresh);
  Future<String?> getRole()         => _storage.read(key: _kRole);
  Future<String?> getUsername()     => _storage.read(key: _kUsername);
  Future<String?> getEmail()        => _storage.read(key: _kEmail);

  Future<bool> hasToken() async {
    final t = await _storage.read(key: _kAccess);
    return t != null && t.isNotEmpty;
  }

  Future<void> clear() => _storage.deleteAll();
}