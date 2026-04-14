import '../entities/report.dart';
import '../repositories/reports_repository.dart';

class AddReportUseCase {
  final ReportsRepository repository;
  const AddReportUseCase(this.repository);
  Future<void> call(Report report) => repository.addReport(report);
}