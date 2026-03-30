import 'package:medixpro/core/network/api_client.dart';
import '../../domain/entities/report.dart';

class ReportsRemoteDataSource {
  final ApiClient api;
  ReportsRemoteDataSource(this.api);

  Future<List<Report>> getReports() async {
    final response = await api.dio.get("/api/v1/reports/");
    final rawData = response.data;

    Map<String, dynamic> toStringKeyMap(Map<dynamic, dynamic> map) {
      return map.map((key, value) => MapEntry(key.toString(), value));
    }

    if (rawData is List) {
      return rawData
          .map((e) => Report.fromJson(e is Map ? toStringKeyMap(e) : {}))
          .toList();
    } else if (rawData is Map) {
      return [Report.fromJson(toStringKeyMap(rawData))];
    } else {
      return [];
    }
  }

  Future<Report> getReportDetail(int id) async {
    final response = await api.dio.get("/api/v1/reports/$id/");
    final rawData = response.data;

    Map<String, dynamic> toStringKeyMap(Map<dynamic, dynamic> map) {
      return map.map((key, value) => MapEntry(key.toString(), value));
    }

    return Report.fromJson(rawData is Map ? toStringKeyMap(rawData) : {});
  }

  Future<Report> addReport(Map<String, dynamic> data) async {
    final response = await api.dio.post("/api/v1/reports/", data: data);
    final rawData = response.data;

    Map<String, dynamic> toStringKeyMap(Map<dynamic, dynamic> map) {
      return map.map((key, value) => MapEntry(key.toString(), value));
    }

    return Report.fromJson(rawData is Map ? toStringKeyMap(rawData) : {});
  }
}