import '../../../../core/network/api_client.dart';
import '../../domain/entities/patient.dart';

class PatientsRemoteDataSource {
  final ApiClient api;
  const PatientsRemoteDataSource(this.api);

  Future<List<Patient>> getPatients() async {
    final response = await api.dio.get("patients/");
    final List data = response.data["data"] as List;
    return data.map((e) => Patient.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> addPatient(Patient patient) async {
    await api.dio.post("patients/", data: patient.toJson());
  }

  Future<void> updatePatient(int id, Patient patient) async {
    await api.dio.put("patients/$id/", data: patient.toJson());
  }

  Future<void> deletePatient(int id) async {
    await api.dio.delete("patients/$id/");
  }
}