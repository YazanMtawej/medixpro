import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_datasource.dart';
import '../models/dashboard_stats_model.dart';
import '../models/today_appointment_model.dart';

class DashboardRepositoryImpl implements DashboardRepository {

  final DashboardRemoteDataSource remote;

  DashboardRepositoryImpl(this.remote);

  @override
  Future<DashboardStatsModel> getStats() {
    return remote.getStats();
  }

  @override
  Future<List<TodayAppointmentModel>> getTodayAppointments() {
    return remote.getTodayAppointments();
  }
}