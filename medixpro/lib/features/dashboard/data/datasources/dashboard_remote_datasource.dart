import '../../../../core/network/api_client.dart';
import '../models/dashboard_stats_model.dart';
import '../models/today_appointment_model.dart';

class DashboardRemoteDataSource {
  final ApiClient apiClient;
  const DashboardRemoteDataSource(this.apiClient);

  Future<DashboardStatsModel> getStats() async {
    final response = await apiClient.dio.get("dashboard/stats/");
    return DashboardStatsModel.fromJson(
        response.data["data"] as Map<String, dynamic>);
  }

  Future<List<TodayAppointmentModel>> getTodayAppointments() async {
    final response =
        await apiClient.dio.get("dashboard/today-appointments/");
    final List data = response.data["data"] as List;
    return data
        .map((e) =>
            TodayAppointmentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}