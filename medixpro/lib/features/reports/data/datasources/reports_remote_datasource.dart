import '../../../../core/network/api_client.dart';
import '../../domain/entities/report.dart';

class ReportsRemoteDataSource {
  final ApiClient api;
  const ReportsRemoteDataSource(this.api);

  Future<List<Report>> getReports({
    int? patientId,
    String? status,
    String? search,
  }) async {
    final response = await api.dio.get(
      "reports/",
      queryParameters: {
        if (patientId != null) "patient": patientId,
        if (status != null && status.isNotEmpty) "status": status,
        if (search != null && search.isNotEmpty) "search": search,
      },
    );
    final List data = response.data["data"] as List;
    return data
        .map((e) => Report.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> addReport(Report report) async {
    await api.dio.post("reports/", data: report.toJson());
  }

  Future<void> updateReport(Report report) async {
    await api.dio.put("reports/${report.id}/", data: report.toJson());
  }

  Future<void> deleteReport(int id) async {
    await api.dio.delete("reports/$id/");
  }
}