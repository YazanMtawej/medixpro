import '../repositories/reports_repository.dart';
import '../entities/report.dart';

class GetReportsUseCase {
  final ReportsRepository repository;
  GetReportsUseCase(this.repository);

  Future<List<Report>> call() => repository.getReports();
}

class AddReportUseCase {
  final ReportsRepository repository;
  AddReportUseCase(this.repository);

  Future<Report> call(Map<String, dynamic> data) => repository.addReport(data);
}