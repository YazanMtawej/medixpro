import '../../domain/entities/appointment.dart';
import '../datasources/appointments_remote_datasource.dart';

class AppointmentsRepositoryImpl {
  final AppointmentsRemoteDataSource remote;
  AppointmentsRepositoryImpl(this.remote);

  Future<List<Appointment>> getAppointments() => remote.getAppointments();

  Future<void> addAppointment(Appointment appointment) =>
      remote.addAppointment(appointment.toJson());

  Future<void> updateAppointment(Appointment appointment) =>
      remote.updateAppointment(appointment.id, appointment.toJson());
}