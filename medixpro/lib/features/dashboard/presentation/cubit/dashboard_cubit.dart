import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_dashboard_stats_usecase.dart';
import '../../domain/usecases/get_today_appointments_usecase.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {

  final GetDashboardStatsUseCase getStats;
  final GetTodayAppointmentsUseCase getAppointments;

  DashboardCubit(this.getStats, this.getAppointments)
      : super(DashboardInitial());

  Future<void> loadDashboard() async {

    emit(DashboardLoading());

    try {

      final stats = await getStats();
      final appointments = await getAppointments();

      emit(DashboardLoaded(stats, appointments));

    } catch (e) {

      emit(DashboardError("Failed to load dashboard"));
    }
  }
}