class LoginRequest {
  final String? username;
  final String? email;
  final String password;
  final String? role; // مطلوب عند التسجيل فقط

  const LoginRequest({
    this.username,
    this.email,
    required this.password,
    this.role,
  });

  void validate({bool isRegister = false}) {
    if ((username == null || username!.isEmpty) &&
        (email == null || email!.isEmpty)) {
      throw Exception("Username or email is required");
    }
    if (password.isEmpty) {
      throw Exception("Password is required");
    }
    if (isRegister && (role == null || role!.isEmpty)) {
      throw Exception("Role is required");
    }
  }

  Map<String, dynamic> toJson() {
    return {
      if (username != null && username!.isNotEmpty) "username": username,
      if (email != null && email!.isNotEmpty) "email": email,
      "password": password,
      if (role != null) "role": role,
    };
  }
}