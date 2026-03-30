import '../entities/user_profile.dart';
import '../repositories/settings_repository.dart';

class GetProfileUseCase {

  final SettingsRepository repository;

  GetProfileUseCase(this.repository);

  Future<UserProfile> call(){
    return repository.getProfile();
  }
}