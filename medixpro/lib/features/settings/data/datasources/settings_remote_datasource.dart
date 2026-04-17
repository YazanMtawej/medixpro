import '../../../../core/network/api_client.dart';
import '../../domain/entities/notification_item.dart';
import '../../domain/entities/user_profile.dart';

class SettingsRemoteDataSource {
  final ApiClient api;
  const SettingsRemoteDataSource(this.api);

  Future<UserProfile> getProfile() async {
    final response = await api.dio.get("profile/");
    return UserProfile.fromJson(
        response.data as Map<String, dynamic>);
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    await api.dio.put("profile/", data: data);
  }

  Future<Map<String, dynamic>> getNotifications() async {
    final response = await api.dio.get("notifications/");
    final body = response.data["data"] as Map<String, dynamic>;
    final List raw = body["notifications"] as List;
    return {
      "unread_count": body["unread_count"] ?? 0,
      "notifications": raw
          .map((e) =>
              NotificationItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    };
  }

  Future<void> markAsRead(int id) async {
    await api.dio.patch("notifications/$id/");
  }

  Future<void> markAllAsRead() async {
    await api.dio.post("notifications/mark-all-read/");
  }

  Future<void> deleteNotification(int id) async {
    await api.dio.delete("notifications/$id/");
  }

  Future<void> clearAllNotifications() async {
    await api.dio.delete("notifications/clear-all/");
  }

  Future<void> logout(String refreshToken) async {
    await api.dio.post("auth/logout/", data: {"refresh": refreshToken});
  }
}