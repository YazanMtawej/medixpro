import '../entities/login_request.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;
  const LoginUseCase(this._repository);

  Future<User> call(LoginRequest request) {
    final identifier = request.username?.isNotEmpty == true
        ? request.username!
        : request.email ?? "";
    return _repository.login(identifier, request.password);
  }
}