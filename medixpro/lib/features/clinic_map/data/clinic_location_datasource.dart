import 'package:medixpro/core/network/api_client.dart';

/// A clinic position plus its descriptive labels.
class ClinicLocation {
  final double latitude;
  final double longitude;
  final String clinicName;
  final String address;

  const ClinicLocation({
    required this.latitude,
    required this.longitude,
    this.clinicName = "",
    this.address = "",
  });
}

/// Talks to the backend for reading the doctor's clinic location
/// (patient side) and for saving it (doctor side).
class ClinicLocationDataSource {
  final ApiClient api;
  const ClinicLocationDataSource(this.api);

  /// Patient: fetch the doctor's clinic location.
  /// Returns null when no doctor has set a location yet (HTTP 404).
  Future<ClinicLocation?> fetchClinicLocation() async {
    final res = await api.dio.get("clinic-location/");
    final data = res.data["data"] as Map<String, dynamic>?;
    if (data == null) return null;

    final lat = (data["latitude"] as num?)?.toDouble();
    final lng = (data["longitude"] as num?)?.toDouble();
    if (lat == null || lng == null) return null;

    return ClinicLocation(
      latitude: lat,
      longitude: lng,
      clinicName: data["clinic_name"] ?? "",
      address: data["address"] ?? "",
    );
  }

  /// Doctor: read the location already saved on the logged-in profile (if any).
  Future<ClinicLocation?> fetchMyLocation() async {
    final res = await api.dio.get("profile/");
    final data = res.data["data"] as Map<String, dynamic>?;
    if (data == null) return null;

    final lat = (data["latitude"] as num?)?.toDouble();
    final lng = (data["longitude"] as num?)?.toDouble();
    if (lat == null || lng == null) return null;

    return ClinicLocation(
      latitude: lat,
      longitude: lng,
      clinicName: data["clinic_name"] ?? "",
      address: data["address"] ?? "",
    );
  }

  /// Doctor: persist the picked clinic coordinates on the profile.
  Future<void> saveClinicLocation(double latitude, double longitude) async {
    await api.dio.put("profile/", data: {
      "latitude": latitude,
      "longitude": longitude,
    });
  }
}
