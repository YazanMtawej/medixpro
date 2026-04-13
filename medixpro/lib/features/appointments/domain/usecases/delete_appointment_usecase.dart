import '../repositories/appointments_repository.dart';

class DeleteAppointmentUseCase {
  final AppointmentsRepository repository;
  const DeleteAppointmentUseCase(this.repository);
  Future<void> call(int id) => repository.deleteAppointment(id);
}