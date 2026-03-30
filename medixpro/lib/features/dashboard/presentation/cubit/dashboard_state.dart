import '../../data/models/dashboard_stats_model.dart';
import '../../data/models/today_appointment_model.dart';

abstract class DashboardState {}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {

  final DashboardStatsModel stats;
  final List<TodayAppointmentModel> appointments;

  DashboardLoaded(this.stats, this.appointments);
}

class DashboardError extends DashboardState {

  final String message;

  DashboardError(this.message);
}