import '../../../../core/network/api_client.dart';

class AuthRemoteDataSource {
  final ApiClient api;
  const AuthRemoteDataSource(this.api);

  Future<Map<String, dynamic>> login(
      String username, String password) async {
    final response = await api.dio.post(
      "auth/login/",
      data: {"username": username, "password": password},
    );
    // ✅ Django يرجع: {"success": true, "data": {"access": ..., "refresh": ..., "user": {...}}}
    final body = response.data as Map<String, dynamic>;
    final data = body["data"] as Map<String, dynamic>?;
    if (data != null) return data;
    // fallback لو جاء مباشرة
    return body;
  }

  Future<Map<String, dynamic>> register(
      Map<String, dynamic> requestData) async {
    final response =
        await api.dio.post("auth/register/", data: requestData);
    final body = response.data as Map<String, dynamic>;
    final data = body["data"] as Map<String, dynamic>?;
    if (data != null) return data;
    return body;
  }

  Future<void> logout(String refreshToken) async {
    try {
      await api.dio
          .post("auth/logout/", data: {"refresh": refreshToken});
    } catch (_) {
      // فشل الـ server لا يمنع تسجيل الخروج محلياً
    }
  }
}