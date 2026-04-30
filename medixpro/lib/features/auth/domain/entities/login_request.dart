class LoginRequest {
  final String? username;
  final String? email;
  final String  password;
  final String? role;
  final String? doctorSecretKey;
  final Map<String, dynamic> extra;

  const LoginRequest({
    this.username,
    this.email,
    required this.password,
    this.role,
    this.doctorSecretKey,
    this.extra = const {},
  });

  Map<String, dynamic> toJson() => {
    if (username != null && username!.isNotEmpty) "username": username,
    if (email    != null && email!.isNotEmpty)    "email":    email,
    "password": password,
    if (role            != null) "role":              role,
    if (doctorSecretKey != null) "doctor_secret_key": doctorSecretKey,
    ...extra,
  };
}