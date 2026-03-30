import '../../../../core/network/api_client.dart';
import '../models/dashboard_stats_model.dart';
import '../models/today_appointment_model.dart';

class DashboardRemoteDataSource {

  final ApiClient apiClient;

  DashboardRemoteDataSource(this.apiClient);

  Future<DashboardStatsModel> getStats() async {

    final response = await apiClient.dio.get("dashboard/stats/");

    return DashboardStatsModel.fromJson(response.data);
  }

  Future<List<TodayAppointmentModel>> getTodayAppointments() async {

    final response =
        await apiClient.dio.get("dashboard/today-appointments/");

    return (response.data as List)
        .map((e) => TodayAppointmentModel.fromJson(e))
        .toList();
  }
}