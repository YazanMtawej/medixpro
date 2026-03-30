import 'package:medixpro/features/settings/domain/entities/notification_item.dart';
import 'package:medixpro/features/settings/domain/entities/user_profile.dart';

abstract class SettingsRepository {
  Future<void> logout(String refreshToken); // ✅ يحتاج refreshToken
  Future<UserProfile> getProfile();
  Future<void> updateProfile(Map<String, dynamic> data);
  Future<List<NotificationItem>> getNotifications();
}