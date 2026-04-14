import '../repositories/reports_repository.dart';

class DeleteReportUseCase {
  final ReportsRepository repository;
  const DeleteReportUseCase(this.repository);
  Future<void> call(int id) => repository.deleteReport(id);
}