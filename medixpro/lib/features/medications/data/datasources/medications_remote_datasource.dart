import '../../../../core/network/api_client.dart';
import '../../domain/entities/medication.dart';

class MedicationsRemoteDataSource {
  final ApiClient api;
  const MedicationsRemoteDataSource(this.api);

  Future<List<Medication>> getMedications({int? patientId, String? search}) async {
    final response = await api.dio.get(
      "medications/",
      queryParameters: {
        if (patientId != null) "patient": patientId,
        if (search != null && search.isNotEmpty) "search": search,
      },
    );
    final List data = response.data["data"] as List;
    return data.map((e) => Medication.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<CommonMedication>> getCommonMedications({String? search}) async {
    final response = await api.dio.get(
      "common-medications/",
      queryParameters: {
        if (search != null && search.isNotEmpty) "search": search,
      },
    );
    final List data = response.data["data"] as List;
    return data.map((e) => CommonMedication.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> addMedication(Medication med) async {
    await api.dio.post("medications/", data: med.toJson());
  }

  Future<void> updateMedication(Medication med) async {
    await api.dio.put("medications/${med.id}/", data: med.toJson());
  }

  Future<void> deleteMedication(int id) async {
    await api.dio.delete("medications/$id/");
  }
}