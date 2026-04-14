import '../entities/report.dart';
import '../repositories/reports_repository.dart';

class GetReportsUseCase {
  final ReportsRepository repository;
  const GetReportsUseCase(this.repository);

  Future<List<Report>> call({
    int? patientId,
    String? status,
    String? search,
  }) =>
      repository.getReports(
          patientId: patientId, status: status, search: search);
}