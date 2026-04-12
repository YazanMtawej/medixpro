import '../entities/login_request.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> login(LoginRequest request);
  Future<User> register(LoginRequest request);
  Future<User?> getLoggedInUser();
  Future<bool> isLoggedIn();
  Future<void> logout(String refreshToken);
}