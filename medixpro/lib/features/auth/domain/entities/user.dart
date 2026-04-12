class User {
  final String username;
  final String email;
  final String role; // "doctor" | "patient"
  final String? fullName;
  final String? clinicName;
  final String? avatar;

  const User({
    required this.username,
    required this.email,
    required this.role,
    this.fullName,
    this.clinicName,
    this.avatar,
  });

  bool get isDoctor => role == "doctor";
  bool get isPatient => role == "patient";
}