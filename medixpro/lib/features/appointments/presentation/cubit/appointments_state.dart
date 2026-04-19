import '../../domain/entities/appointment.dart';
import '../../domain/entities/appointment_request.dart';

abstract class AppointmentsState {}

class AppointmentsInitial  extends AppointmentsState {}
class AppointmentsLoading  extends AppointmentsState {}
class AppointmentsError    extends AppointmentsState {
  final String message;
  AppointmentsError(this.message);
}

class AppointmentsLoaded extends AppointmentsState {
  final List<Appointment> appointments;
  AppointmentsLoaded(this.appointments);
}

class RequestsLoaded extends AppointmentsState {
  final List<AppointmentRequest> requests;
  RequestsLoaded(this.requests);
}

class RequestActionSuccess extends AppointmentsState {
  final String message;
  RequestActionSuccess(this.message);
}