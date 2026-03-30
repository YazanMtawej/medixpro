import '../entities/login_request.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<User> call(LoginRequest request) async {
    return await repository.register(request);
  }
}