import '../../../../core/network/api_client.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/notification_item.dart';

class SettingsRemoteDataSource {
  final ApiClient api;

  SettingsRemoteDataSource(this.api);

  Future<UserProfile> getProfile() async {
    try {
      final response = await api.dio.get("profile/");
      return UserProfile.fromJson(response.data);
    } catch (e) {
      throw Exception("Failed to load profile");
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      await api.dio.put("profile/", data: data);
    } catch (e) {
      throw Exception("Failed to update profile");
    }
  }

  Future<List<NotificationItem>> getNotifications() async {
    try {
      final response = await api.dio.get("notifications/");
      final data = response.data as List;
      return data.map((e) => NotificationItem.fromJson(e)).toList();
    } catch (e) {
      throw Exception("Failed to load notifications");
    }
  }

  Future<void> logout(String refreshToken) async {
    await api.dio.post(
      "auth/logout/",
      data: {"refresh": refreshToken},
    );
  }
}