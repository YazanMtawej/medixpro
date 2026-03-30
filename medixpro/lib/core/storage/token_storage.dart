import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {

  final FlutterSecureStorage _storage;

  const TokenStorage(this._storage);

  static const _accessTokenKey = "access_token";
  static const _refreshTokenKey = "refresh_token";

  /// حفظ access + refresh
  Future<void> saveTokens(String access, String refresh) async {
    await _storage.write(key: _accessTokenKey, value: access);
    await _storage.write(key: _refreshTokenKey, value: refresh);
  }

  /// حفظ access فقط (عند refresh)
  Future<void> saveAccessToken(String access) async {
    await _storage.write(key: _accessTokenKey, value: access);
  }

  Future<String?> getAccessToken() async {
    return _storage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return _storage.read(key: _refreshTokenKey);
  }

  Future<void> clear() async {
    await _storage.deleteAll();
  }
  Future<bool> hasToken() async {
  final token = await getAccessToken();
  return token != null && token.isNotEmpty;
}
}
