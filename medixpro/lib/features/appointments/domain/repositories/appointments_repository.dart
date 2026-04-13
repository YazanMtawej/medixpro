import '../entities/appointment.dart';

abstract class AppointmentsRepository {
  Future<List<Appointment>> getAppointments({int? patientId, String? status, String? search});
  Future<void> addAppointment(Appointment appointment);
  Future<void> updateAppointment(Appointment appointment);
  Future<void> deleteAppointment(int id);
}