import 'package:medixpro/features/auth/data/models/login_response.dart';

import '../../domain/entities/login_request.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../../../../core/storage/token_storage.dart';


class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  final TokenStorage tokenStorage;

  AuthRepositoryImpl(this.remote, this.tokenStorage);

  @override
  Future<User> login(LoginRequest request) async {
    request.validate();

    final data = await remote.login(request.toJson());
    final response = LoginResponse.fromJson(data);

    await tokenStorage.saveTokens(response.access, response.refresh);

    return response.user;
  }

  @override
  Future<User> register(LoginRequest request) async {
    request.validate();

    final data = await remote.register(request.toJson());
    final response = LoginResponse.fromJson(data);

    await tokenStorage.saveTokens(response.access, response.refresh);

    return response.user;
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await tokenStorage.getAccessToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<void> logout() async {
    await tokenStorage.clear();
  }
}