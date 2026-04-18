import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medixpro/core/notifications/notification_service.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/usecases/get_appointments_usecase.dart';
import '../../domain/usecases/add_appointment_usecase.dart';
import '../../domain/usecases/update_appointment_usecase.dart';
import '../../domain/usecases/delete_appointment_usecase.dart';
import 'appointments_state.dart';

class AppointmentsCubit extends Cubit<AppointmentsState> {
  final GetAppointmentsUseCase   _getAppointments;
  final AddAppointmentUseCase    _addAppointment;
  final UpdateAppointmentUseCase _updateAppointment;
  final DeleteAppointmentUseCase _deleteAppointment;

  AppointmentsCubit(
    this._getAppointments,
    this._addAppointment,
    this._updateAppointment,
    this._deleteAppointment,
  ) : super(AppointmentsInitial());

  Future<void> fetchAppointments({
    int? patientId,
    String? status,
    String? search,
  }) async {
    emit(AppointmentsLoading());
    try {
      final data = await _getAppointments(
        patientId: patientId,
        status: status,
        search: search,
      );
      emit(AppointmentsLoaded(data));
    } catch (e) {
      emit(AppointmentsError("Failed to load appointments: $e"));
    }
  }

  Future<void> addNewAppointment(Appointment a) async {
    final String title       = a.title.trim().isNotEmpty       ? a.title.trim()       : "Appointment";
    final String patientName = a.patientName.trim().isNotEmpty ? a.patientName.trim() : "Patient";

    try {
      await _addAppointment(a);

      NotificationService().showNotification(
        id: DateTime.now().millisecondsSinceEpoch % 100000,
        title: "Appointment Scheduled",
        body: "'$title' for $patientName has been created.",
      );

      // تذكير قبل 30 دقيقة إن كان الموعد في المستقبل
      if (a.dateTime.isAfter(DateTime.now().add(const Duration(minutes: 31)))) {
        NotificationService().scheduleNotification(
          id: a.id == 0
              ? DateTime.now().millisecondsSinceEpoch % 100000 + 1
              : a.id,
          title: "⏰ Upcoming Appointment",
          body: "'$title' for $patientName starts in 30 minutes.",
          scheduledTime: a.dateTime.subtract(const Duration(minutes: 30)),
        );
      }

      await fetchAppointments();
    } catch (e) {
      emit(AppointmentsError("Failed to add appointment: $e"));
    }
  }

  Future<void> editAppointment(Appointment a) async {
    final String title  = a.title.trim().isNotEmpty ? a.title.trim() : "Appointment";
    final String status = a.status;

    try {
      await _updateAppointment(a);

      NotificationService().showNotification(
        id: DateTime.now().millisecondsSinceEpoch % 100000,
        title: "Appointment Updated",
        body: "'$title' is now: $status.",
      );

      await fetchAppointments();
    } catch (e) {
      emit(AppointmentsError("Failed to update appointment: $e"));
    }
  }

  Future<void> deleteAppointment(int id) async {
    String title = "Appointment";
    final current = state;
    if (current is AppointmentsLoaded) {
      try {
        title = current.appointments.firstWhere((a) => a.id == id).title;
      } catch (_) {}
    }

    try {
      await _deleteAppointment(id);

      NotificationService().showNotification(
        id: DateTime.now().millisecondsSinceEpoch % 100000,
        title: "Appointment Removed",
        body: "Appointment '$title' has been deleted.",
      );

      await fetchAppointments();
    } catch (e) {
      emit(AppointmentsError("Failed to delete appointment: $e"));
    }
  }
}