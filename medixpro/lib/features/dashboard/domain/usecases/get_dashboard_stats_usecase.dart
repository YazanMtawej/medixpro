import '../repositories/dashboard_repository.dart';
import '../../data/models/dashboard_stats_model.dart';

class GetDashboardStatsUseCase {

  final DashboardRepository repository;

  GetDashboardStatsUseCase(this.repository);

  Future<DashboardStatsModel> call() {
    return repository.getStats();
  }
}