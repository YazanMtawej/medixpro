import '../entities/login_request.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository _repository;
  const RegisterUseCase(this._repository);

  Future<User> call(LoginRequest request) {
    return _repository.register(request.toJson());
  }
}