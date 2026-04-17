import '../repositories/settings_repository.dart';

class UpdateProfileUseCase {
  final SettingsRepository repository;
  const UpdateProfileUseCase(this.repository);
  Future<void> call(Map<String, dynamic> data) =>
      repository.updateProfile(data);
}