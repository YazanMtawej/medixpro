import '../entities/report.dart';

abstract class ReportsRepository {
  Future<List<Report>> getReports({int? patientId, String? status, String? search});
  Future<void> addReport(Report report);
  Future<void> updateReport(Report report);
  Future<void> deleteReport(int id);
}