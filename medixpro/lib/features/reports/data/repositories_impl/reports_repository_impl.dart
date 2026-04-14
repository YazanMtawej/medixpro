import '../../domain/entities/report.dart';
import '../../domain/repositories/reports_repository.dart';
import '../datasources/reports_remote_datasource.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  final ReportsRemoteDataSource remote;
  const ReportsRepositoryImpl(this.remote);

  @override
  Future<List<Report>> getReports({
    int? patientId,
    String? status,
    String? search,
  }) =>
      remote.getReports(
          patientId: patientId, status: status, search: search);

  @override
  Future<void> addReport(Report report) => remote.addReport(report);

  @override
  Future<void> updateReport(Report report) => remote.updateReport(report);

  @override
  Future<void> deleteReport(int id) => remote.deleteReport(id);
}