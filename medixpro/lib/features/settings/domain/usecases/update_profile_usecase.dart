import '../repositories/settings_repository.dart';

class UpdateProfileUseCase {

  final SettingsRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<void> call(Map<String,dynamic> data){
    return repository.updateProfile(data);
  }
}