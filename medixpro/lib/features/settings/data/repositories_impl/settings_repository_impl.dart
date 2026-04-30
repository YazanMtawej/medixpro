import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_remote_datasource.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsRemoteDataSource remote;
  const SettingsRepositoryImpl(this.remote);

  @override
  Future<UserProfile> getProfile() => remote.getProfile();

  @override
  Future<void> updateProfile(Map<String, dynamic> data) =>
      remote.updateProfile(data);

  @override
  Future<Map<String, dynamic>> getNotifications() => remote.getNotifications();

  @override
  Future<void> markAsRead(int id) => remote.markAsRead(id);

  @override
  Future<void> markAllAsRead() => remote.markAllAsRead();

  @override
  Future<void> deleteNotification(int id) => remote.deleteNotification(id);

  @override
  Future<void> clearAllNotifications() => remote.clearAllNotifications();

  @override
  Future<void> logout(String refreshToken) => remote.logout(refreshToken);
  @override
  Future<List<Map<String, dynamic>>> getPatientAccounts() =>
      remote.getPatientAccounts();

  @override
  Future<void> deletePatientAccount(int userId) =>
      remote.deletePatientAccount(userId);
}
