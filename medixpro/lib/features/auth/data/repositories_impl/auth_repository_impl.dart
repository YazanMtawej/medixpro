import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/storage/token_storage.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final TokenStorage         _tokenStorage;

  const AuthRepositoryImpl(this._remote, this._tokenStorage);

  @override
  Future<User> login(String username, String password) async {
    final data = await _remote.login(username, password);
    return _saveAndReturn(data, fallbackUsername: username);
  }

  @override
  Future<User> register(Map<String, dynamic> requestData) async {
    final data = await _remote.register(requestData);
    return _saveAndReturn(
      data,
      fallbackRole: requestData["role"] as String? ?? "patient",
    );
  }

  @override
  Future<void> logout(String refreshToken) async {
    await _remote.logout(refreshToken);
    await _tokenStorage.clear();
  }

  @override
  Future<User?> autoLogin() async {
    try {
      final hasToken = await _tokenStorage.hasToken();
      if (!hasToken) {
        // ignore: avoid_print
        print("ℹ️ autoLogin: no token");
        return null;
      }
      final username = await _tokenStorage.getUsername();
      final role     = await _tokenStorage.getRole();
      final email    = await _tokenStorage.getEmail();

      if (username == null || username.isEmpty) {
        // ignore: avoid_print
        print("ℹ️ autoLogin: no username");
        return null;
      }
      // ignore: avoid_print
      print("✅ autoLogin: $username ($role)");
      return User(username: username, email: email ?? "", role: role ?? "patient");
    } catch (e) {
      // ignore: avoid_print
      print("❌ autoLogin error: $e");
      return null;
    }
  }

  // ─── Helper ────────────────────────────────────────────────────────────────
  Future<User> _saveAndReturn(
    Map<String, dynamic> data, {
    String fallbackUsername = "",
    String fallbackRole     = "patient",
  }) async {
    final access  = data["access"]  as String? ?? "";
    final refresh = data["refresh"] as String? ?? "";
    final userMap = data["user"]    as Map<String, dynamic>? ?? {};

    if (access.isEmpty) throw Exception("Server returned no access token");

    final role     = userMap["role"]     as String? ?? fallbackRole;
    final username = userMap["username"] as String? ?? fallbackUsername;
    final email    = userMap["email"]    as String? ?? "";

    // ✅ sequential — لا race condition
    await _tokenStorage.saveTokens(access, refresh, role: role);
    await _tokenStorage.saveUserInfo(username, email);

    // تحقق فوري
    final check = await _tokenStorage.getAccessToken();
    // ignore: avoid_print
    print("✅ Token saved & verified: ${check != null ? 'OK' : 'FAILED'}");
    // ignore: avoid_print
    print("   role=$role | user=$username");

    return User(
      username:   username,
      email:      email,
      role:       role,
      fullName:   userMap["full_name"]   as String?,
      clinicName: userMap["clinic_name"] as String?,
    );
  }
  @override
Future<void> verifyDoctorKey(String code) {
  return _remote.verifyDoctorKey(code);
}
}