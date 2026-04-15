import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_dashboard_stats_usecase.dart';
import '../../domain/usecases/get_today_appointments_usecase.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final GetDashboardStatsUseCase    _getStats;
  final GetTodayAppointmentsUseCase _getAppointments;

  DashboardCubit(this._getStats, this._getAppointments)
      : super(DashboardInitial());

  Future<void> loadDashboard() async {
    emit(DashboardLoading());
    try {
      final stats        = await _getStats();
      final appointments = await _getAppointments();
      emit(DashboardLoaded(stats, appointments));
    } catch (_) {
      emit(DashboardError("Failed to load dashboard"));
    }
  }
}