import 'package:medixpro/features/appointments/data/repositories_impl/appointments_repository_impl.dart';
import 'package:medixpro/features/appointments/domain/entities/appointment.dart';

class GetAppointmentsUseCase {
  final AppointmentsRepositoryImpl repository;
  GetAppointmentsUseCase(this.repository);
  Future<List<Appointment>> call() => repository.getAppointments();
}