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

  final _notif = NotificationService();

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
    } catch (_) {
      emit(AppointmentsError("Failed to load appointments"));
    }
  }

  Future<void> addNewAppointment(Appointment a) async {
    try {
      final title       = a.title.trim();
      final patientName = a.patientName.trim();

      await _addAppointment(a);

      await _notif.notifyAppointmentCreated(
        title.isNotEmpty       ? title       : "Appointment",
        patientName.isNotEmpty ? patientName : "Patient",
      );

      // جدولة تذكير قبل 30 دقيقة إذا كان الموعد في المستقبل
      if (a.dateTime.isAfter(DateTime.now().add(const Duration(minutes: 31)))) {
        await _notif.scheduleAppointmentReminder(
          id:              a.id == 0 ? DateTime.now().millisecondsSinceEpoch % 100000 : a.id,
          title:           title,
          patientName:     patientName.isNotEmpty ? patientName : "Patient",
          appointmentTime: a.dateTime,
        );
      }

      await fetchAppointments();
    } catch (_) {
      emit(AppointmentsError("Failed to add appointment"));
    }
  }

  Future<void> editAppointment(Appointment a) async {
    try {
      final title  = a.title.trim();
      final status = a.status;

      await _updateAppointment(a);
      await _notif.notifyAppointmentUpdated(
        title.isNotEmpty ? title : "Appointment",
        status,
      );

      await fetchAppointments();
    } catch (_) {
      emit(AppointmentsError("Failed to update appointment"));
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
      // إلغاء التذكير المجدول إذا وُجد
      await _notif.cancel(id);

      await _deleteAppointment(id);
      await _notif.notifyAppointmentDeleted(title);
      await fetchAppointments();
    } catch (_) {
      emit(AppointmentsError("Failed to delete appointment"));
    }
  }
}