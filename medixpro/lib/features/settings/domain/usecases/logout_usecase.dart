import '../repositories/settings_repository.dart';


class LogoutUseCase {
  final SettingsRepository repository;

  LogoutUseCase(this.repository);

  Future<void> call(String refreshToken) async {
    await repository.logout(refreshToken); // ✅ تمرير refreshToken
  }
}