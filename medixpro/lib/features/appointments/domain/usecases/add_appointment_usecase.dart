import '../entities/appointment.dart';
import '../repositories/appointments_repository.dart';

class AddAppointmentUseCase {
  final AppointmentsRepository repository;
  const AddAppointmentUseCase(this.repository);
  Future<void> call(Appointment a) => repository.addAppointment(a);
}