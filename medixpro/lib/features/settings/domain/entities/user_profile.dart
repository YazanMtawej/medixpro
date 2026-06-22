class UserProfile {
  final int    id;
  final String username;
  final String email;
  final String role;
  final String fullName;
  final String clinicName;
  final String address;
  final double? latitude;
  final double? longitude;
  final String? avatar;

  const UserProfile({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.fullName,
    required this.clinicName,
    required this.address,
    this.latitude,
    this.longitude,
    this.avatar,
  });

  bool get isDoctor => role == "doctor";

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final data = json["data"] ?? json;
    return UserProfile(
      id:         data["id"]          ?? 0,
      username:   data["username"]    ?? "",
      email:      data["email"]       ?? "",
      role:       data["role"]        ?? "patient",
      fullName:   data["full_name"]   ?? "",
      clinicName: data["clinic_name"] ?? "",
      address:    data["address"]     ?? "",
      latitude:   (data["latitude"]  as num?)?.toDouble(),
      longitude:  (data["longitude"] as num?)?.toDouble(),
      avatar:     data["avatar"],
    );
  }
}