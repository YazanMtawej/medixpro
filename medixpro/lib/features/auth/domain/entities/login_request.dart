class LoginRequest {
  final String? username;
  final String? email;
  final String password;

  LoginRequest({
    this.username,
    this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      "username": username,
      "email": email,
      "password": password,
    };
  }

  void validate() {
    if ((username == null || username!.isEmpty) &&
        (email == null || email!.isEmpty)) {
      throw Exception("Username or Email is required");
    }

    if (password.isEmpty) {
      throw Exception("Password is required");
    }
  }
}