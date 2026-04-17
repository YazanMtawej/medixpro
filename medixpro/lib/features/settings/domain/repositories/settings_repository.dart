import '../entities/user_profile.dart';

abstract class SettingsRepository {
  Future<UserProfile>              getProfile();
  Future<void>                     updateProfile(Map<String, dynamic> data);
  Future<Map<String, dynamic>>     getNotifications();
  Future<void>                     markAsRead(int id);
  Future<void>                     markAllAsRead();
  Future<void>                     deleteNotification(int id);
  Future<void>                     clearAllNotifications();
  Future<void>                     logout(String refreshToken);
}