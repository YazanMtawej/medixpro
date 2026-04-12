import '../../domain/entities/login_request.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/login_response.dart';
import '../../../../core/storage/token_storage.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  final TokenStorage tokenStorage;

  const AuthRepositoryImpl(this.remote, this.tokenStorage);

  @override
  Future<User> login(LoginRequest request) async {
    request.validate();
    final data = await remote.login(request.toJson());
    final response = LoginResponse.fromJson(data);
    await tokenStorage.saveTokens(
      response.access,
      response.refresh,
      role: response.user.role,
    );
    return response.user;
  }

  @override
  Future<User> register(LoginRequest request) async {
    request.validate(isRegister: true);
    final data = await remote.register(request.toJson());
    final response = LoginResponse.fromJson(data);
    await tokenStorage.saveTokens(
      response.access,
      response.refresh,
      role: response.user.role,
    );
    return response.user;
  }

  @override
  Future<void> logout(String refreshToken) async {
    await remote.logout(refreshToken);
    await tokenStorage.clear();
  }

  @override
  Future<bool> isLoggedIn() async => tokenStorage.hasToken();

  @override
  Future<User?> getLoggedInUser() async {
    final username = await tokenStorage.getUsername();
    final email = await tokenStorage.getEmail();
    final role = await tokenStorage.getRole();
    if (username == null || email == null || role == null) return null;
    return User(username: username, email: email, role: role);
  }
}