import '../repositories/settings_repository.dart';

class LogoutUseCase {
  final SettingsRepository repository;
  const LogoutUseCase(this.repository);
  Future<void> call(String refreshToken) =>
      repository.logout(refreshToken);
}