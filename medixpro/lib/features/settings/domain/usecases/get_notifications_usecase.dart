import '../repositories/settings_repository.dart';

class GetNotificationsUseCase {
  final SettingsRepository repository;
  const GetNotificationsUseCase(this.repository);
  Future<Map<String, dynamic>> call() => repository.getNotifications();
}