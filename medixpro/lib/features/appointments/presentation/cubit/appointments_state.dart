part of 'appointments_cubit.dart';

abstract class AppointmentsState {}
class AppointmentsInitial extends AppointmentsState {}
class AppointmentsLoading extends AppointmentsState {}
class AppointmentsLoaded extends AppointmentsState {
  final List<Appointment> appointments;
  AppointmentsLoaded(this.appointments);
}
class AppointmentsError extends AppointmentsState {
  final String message;
  AppointmentsError(this.message);
}