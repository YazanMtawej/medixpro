import '../../domain/entities/user.dart';

class LoginResponse {
  final String access;
  final String refresh;
  final User user;

  const LoginResponse({
    required this.access,
    required this.refresh,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final userJson = json["user"] as Map<String, dynamic>;
    return LoginResponse(
      access: json["access"] as String,
      refresh: json["refresh"] as String,
      user: User(
        username: userJson["username"] as String,
        email: userJson["email"] as String,
        role: userJson["role"] as String,
        fullName: userJson["full_name"] as String?,
        clinicName: userJson["clinic_name"] as String?,
        avatar: userJson["avatar"] as String?,
      ),
    );
  }
}