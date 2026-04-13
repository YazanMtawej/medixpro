import '../../domain/entities/appointment.dart';
import '../../domain/repositories/appointments_repository.dart';
import '../datasources/appointments_remote_datasource.dart';

class AppointmentsRepositoryImpl implements AppointmentsRepository {
  final AppointmentsRemoteDataSource remote;
  const AppointmentsRepositoryImpl(this.remote);

  @override
  Future<List<Appointment>> getAppointments({
    int? patientId,
    String? status,
    String? search,
  }) =>
      remote.getAppointments(
          patientId: patientId, status: status, search: search);

  @override
  Future<void> addAppointment(Appointment a) => remote.addAppointment(a);

  @override
  Future<void> updateAppointment(Appointment a) =>
      remote.updateAppointment(a);

  @override
  Future<void> deleteAppointment(int id) => remote.deleteAppointment(id);
}