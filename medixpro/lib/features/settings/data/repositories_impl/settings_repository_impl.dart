import '../../domain/entities/user_profile.dart';
import '../../domain/entities/notification_item.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_remote_datasource.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsRemoteDataSource remote;

  SettingsRepositoryImpl(this.remote);

  @override
  Future<void> logout(String refreshToken) {
    return remote.logout(refreshToken); // ✅ استدعاء صحيح مع التوكن
  }

  @override
  Future<UserProfile> getProfile() {
    return remote.getProfile();
  }

  @override
  Future<void> updateProfile(Map<String, dynamic> data) {
    return remote.updateProfile(data);
  }

  @override
  Future<List<NotificationItem>> getNotifications() {
    return remote.getNotifications();
  }
}