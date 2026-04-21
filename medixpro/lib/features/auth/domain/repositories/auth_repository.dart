import '../entities/user.dart';

abstract class AuthRepository {
  Future<User>  login(String username, String password);
  Future<User>  register(Map<String, dynamic> data);
  Future<void>  logout(String refreshToken);
  Future<User?> autoLogin();
}