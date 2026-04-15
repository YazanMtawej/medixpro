import '../repositories/dashboard_repository.dart';
import '../../data/models/today_appointment_model.dart';

class GetTodayAppointmentsUseCase {
  final DashboardRepository repository;
  const GetTodayAppointmentsUseCase(this.repository);
  Future<List<TodayAppointmentModel>> call() =>
      repository.getTodayAppointments();
}