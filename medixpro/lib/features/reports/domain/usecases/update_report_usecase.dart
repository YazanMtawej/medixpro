import '../entities/report.dart';
import '../repositories/reports_repository.dart';

class UpdateReportUseCase {
  final ReportsRepository repository;
  const UpdateReportUseCase(this.repository);
  Future<void> call(Report report) => repository.updateReport(report);
}