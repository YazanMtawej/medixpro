import '../../data/models/dashboard_stats_model.dart';
import '../../data/models/today_appointment_model.dart';

abstract class DashboardRepository {

  Future<DashboardStatsModel> getStats();

  Future<List<TodayAppointmentModel>> getTodayAppointments();
}