
import 'package:medixpro/features/appointments/data/repositories_impl/appointments_repository_impl.dart';
import 'package:medixpro/features/appointments/domain/entities/appointment.dart';

class UpdateAppointmentUseCase {
  final AppointmentsRepositoryImpl repository;
  UpdateAppointmentUseCase(this.repository);
  Future<void> call(Appointment appointment) => repository.updateAppointment(appointment);
}