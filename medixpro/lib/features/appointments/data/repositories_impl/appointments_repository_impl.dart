import '../../domain/entities/appointment.dart';
import '../../domain/entities/appointment_request.dart';
import '../../domain/repositories/appointments_repository.dart';
import '../datasources/appointments_remote_datasource.dart';

class AppointmentsRepositoryImpl implements AppointmentsRepository {
  final AppointmentsRemoteDataSource remote;
  const AppointmentsRepositoryImpl(this.remote);

  @override
  Future<List<Appointment>> getAppointments({int? patientId, String? status, String? search}) =>
      remote.getAppointments(patientId: patientId, status: status, search: search);

  @override
  Future<void> addAppointment(Appointment a)    => remote.addAppointment(a);

  @override
  Future<void> updateAppointment(Appointment a) => remote.updateAppointment(a);

  @override
  Future<void> deleteAppointment(int id)        => remote.deleteAppointment(id);

  @override
  Future<List<AppointmentRequest>> getRequests() => remote.getRequests();

  @override
  Future<void> sendRequest(AppointmentRequest r) => remote.sendRequest(r);

  @override
  Future<void> acceptRequest(int id, {String notes = ""}) => remote.acceptRequest(id, notes: notes);

  @override
  Future<void> rejectRequest(int id, {String doctorNote = ""}) => remote.rejectRequest(id, doctorNote: doctorNote);

  @override
  Future<void> suggestAlternative(int id, String suggestedDate, String note) =>
      remote.suggestAlternative(id, suggestedDate, note);

  @override
  Future<void> confirmSuggestion(int id) => remote.confirmSuggestion(id);
}