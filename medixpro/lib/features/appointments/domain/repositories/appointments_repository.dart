import '../entities/appointment.dart';
import '../entities/appointment_request.dart';

abstract class AppointmentsRepository {
  Future<List<Appointment>> getAppointments({int? patientId, String? status, String? search});
  Future<void> addAppointment(Appointment a);
  Future<void> updateAppointment(Appointment a);
  Future<void> deleteAppointment(int id);

  Future<List<AppointmentRequest>> getRequests();
  Future<void> sendRequest(AppointmentRequest r);
  Future<void> acceptRequest(int id, {String notes});
  Future<void> rejectRequest(int id, {String doctorNote});
  Future<void> suggestAlternative(int id, String suggestedDate, String note);
  Future<void> confirmSuggestion(int id);
}