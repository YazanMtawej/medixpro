import '../entities/appointment.dart';
import '../repositories/appointments_repository.dart';

class UpdateAppointmentUseCase {
  final AppointmentsRepository repository;
  const UpdateAppointmentUseCase(this.repository);
  Future<void> call(Appointment a) => repository.updateAppointment(a);
}