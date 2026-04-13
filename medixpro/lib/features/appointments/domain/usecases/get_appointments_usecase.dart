import '../entities/appointment.dart';
import '../repositories/appointments_repository.dart';

class GetAppointmentsUseCase {
  final AppointmentsRepository repository;
  const GetAppointmentsUseCase(this.repository);

  Future<List<Appointment>> call({
    int? patientId,
    String? status,
    String? search,
  }) =>
      repository.getAppointments(
          patientId: patientId, status: status, search: search);
}