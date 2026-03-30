import '../../../../core/network/api_client.dart';
import '../../domain/entities/medication.dart';

class MedicationsRemoteDataSource {
  final ApiClient api;

  MedicationsRemoteDataSource(this.api);

  Future<List<Medication>> getMedications({int? patientId}) async {
    final response = await api.dio.get(
      "medications/",
      queryParameters: patientId != null ? {"patient": patientId} : null,
    );

    final List data = response.data;

    return data.map((e) => Medication.fromJson(e)).toList();
  }

  Future<void> addMedication(Medication med) async {
    await api.dio.post(
      "medications/",
      data: med.toJson(),
    );
  }

  Future<void> updateMedication(Medication med) async {
    await api.dio.put(
      "medications/${med.id}/",
      data: med.toJson(),
    );
  }

  Future<void> deleteMedication(int id) async {
    await api.dio.delete("medications/$id/");
  }
}