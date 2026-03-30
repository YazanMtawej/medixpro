import 'package:dio/dio.dart';
import '../entities/report.dart';

class ReportsRepository {
  final Dio dio;

  ReportsRepository(this.dio);

  Future<List<Report>> getReports() async {
    final res = await dio.get('/api/v1/reports/');
    return (res.data as List).map((e) => Report.fromJson(e)).toList();
  }

  Future<void> createReport(Report report) async {
    await dio.post('/api/v1/reports/', data: report.toJson());
  }

  Future<Report> getReportDetail(int id) async {
    final res = await dio.get('/api/v1/reports/$id/');
    return Report.fromJson(res.data);
  }

  Future<Report> addReport(Map<String, dynamic> data) async {
    final res = await dio.post('/api/v1/reports/', data: data);
    return Report.fromJson(res.data);
  }
}