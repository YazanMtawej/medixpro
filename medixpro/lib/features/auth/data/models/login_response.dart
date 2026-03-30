import '../../domain/entities/user.dart';

class LoginResponse {
  final String access;
  final String refresh;
  final User user;

  LoginResponse({
    required this.access,
    required this.refresh,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      access: json["access"],
      refresh: json["refresh"],
      user: User(
        username: json["user"]["username"],
        email: json["user"]["email"],
      ),
    );
  }
}