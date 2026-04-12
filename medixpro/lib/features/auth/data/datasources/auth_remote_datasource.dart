import 'package:medixpro/core/network/api_client.dart';

class AuthRemoteDataSource {
  final ApiClient api;
  const AuthRemoteDataSource(this.api);

  Future<Map<String, dynamic>> login(Map<String, dynamic> data) async {
    final response = await api.dio.post("auth/login/", data: data);
    return response.data["data"] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    final response = await api.dio.post("auth/register/", data: data);
    return response.data["data"] as Map<String, dynamic>;
  }

  Future<void> logout(String refreshToken) async {
    await api.dio.post("auth/logout/", data: {"refresh": refreshToken});
  }
}