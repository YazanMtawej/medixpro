import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/patient.dart';

class PatientsRemoteDataSource {
  final ApiClient api;

  PatientsRemoteDataSource(this.api);

  Future<List<Patient>> getPatients() async {
    final response = await api.dio.get("patients/");
    final List data = response.data;
    return data.map((e) => Patient.fromJson(e)).toList();
  }

  Future<void> addPatient(Patient patient) async {
    try {
      final data = patient.toJson();

      print("🚀 SEND PATIENT: $data");

      await api.dio.post(
        "patients/",
        data: data,
      );
    } on DioException catch (e) {
      print("❌ ERROR DATA: ${e.response?.data}");
      rethrow;
    }
  }

  Future<void> updatePatient(int id, Patient patient) async {
    try {
      final data = patient.toJson();

      await api.dio.put(
        "patients/$id/",
        data: data,
      );
    } on DioException catch (e) {
      print("❌ UPDATE ERROR: ${e.response?.data}");
      rethrow;
    }
  }

  Future<void> deletePatient(int id) async {
    await api.dio.delete("patients/$id/");
  }
}