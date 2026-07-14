import 'package:dio/dio.dart';
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

  /// Doctor: persist the picked clinic coordinates (and optional descriptive
  /// labels) on the profile.
  Future<void> saveClinicLocation(
    double latitude,
    double longitude, {
    String? clinicName,
    String? address,
  }) async {
    await api.dio.put("profile/", data: {
      "latitude": latitude,
      "longitude": longitude,
      if (clinicName != null) "clinic_name": clinicName,
      if (address != null) "address": address,
    });
  }

  /// Reverse-geocode a point into a human-readable address using the free
  /// OpenStreetMap Nominatim service (same data source as the map tiles, no
  /// API key required). Returns null on any failure — callers should treat the
  /// address as simply unavailable.
  Future<String?> reverseGeocode(double latitude, double longitude) async {
    try {
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 8),
        headers: {
          // Nominatim's usage policy requires a descriptive User-Agent.
          "User-Agent": "com.medixpro.app",
        },
      ));
      final res = await dio.get(
        "https://nominatim.openstreetmap.org/reverse",
        queryParameters: {
          "lat": latitude,
          "lon": longitude,
          "format": "jsonv2",
          "zoom": 18,
          "addressdetails": 0,
        },
      );
      final name = res.data is Map ? res.data["display_name"] : null;
      if (name is String && name.trim().isNotEmpty) return name.trim();
      return null;
    } catch (_) {
      return null;
    }
  }
}
