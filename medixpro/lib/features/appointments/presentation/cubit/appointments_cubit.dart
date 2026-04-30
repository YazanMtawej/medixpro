import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medixpro/core/errors/app_error_handler.dart';
import 'package:medixpro/core/notifications/notification_service.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/entities/appointment_request.dart';
import '../../domain/repositories/appointments_repository.dart';
import 'appointments_state.dart';

class AppointmentsCubit extends Cubit<AppointmentsState> {
  final AppointmentsRepository _repo;
  AppointmentsCubit(this._repo) : super(AppointmentsInitial());

  // ─── Appointments ─────────────────────────────────────────────────────────

  Future<void> fetchAppointments({
    int? patientId, String? status, String? search,
  }) async {
    emit(AppointmentsLoading());
    try {
      final data = await _repo.getAppointments(
          patientId: patientId, status: status, search: search);
      emit(AppointmentsLoaded(data));
    } catch (e) {
      emit(AppointmentsError(
          AppErrorHandler.handle(e, context: "fetchAppointments")));
    }
  }

  Future<void> addNewAppointment(Appointment a) async {
    final title       = a.title.trim().isNotEmpty       ? a.title.trim()       : "Appointment";
    final patientName = a.patientName.trim().isNotEmpty ? a.patientName.trim() : "Patient";
    try {
      await _repo.addAppointment(a);
      NotificationService().showNotification(
        id:    DateTime.now().millisecondsSinceEpoch % 100000,
        title: "Appointment Scheduled",
        body:  "'$title' for $patientName has been created.",
      );
      await fetchAppointments();
    } catch (e) {
      emit(AppointmentsError(
          AppErrorHandler.handle(e, context: "addAppointment")));
    }
  }

  Future<void> editAppointment(Appointment a) async {
    try {
      await _repo.updateAppointment(a);
      NotificationService().showNotification(
        id:    DateTime.now().millisecondsSinceEpoch % 100000,
        title: "Appointment Updated",
        body:  "'${a.title}' is now: ${a.status}.",
      );
      await fetchAppointments();
    } catch (e) {
      emit(AppointmentsError(
          AppErrorHandler.handle(e, context: "editAppointment")));
    }
  }

  Future<void> deleteAppointment(int id) async {
    String title = "Appointment";
    final cur    = state;
    if (cur is AppointmentsLoaded) {
      try { title = cur.appointments.firstWhere((a) => a.id == id).title; }
      catch (_) {}
    }
    try {
      await _repo.deleteAppointment(id);
      NotificationService().showNotification(
        id:    DateTime.now().millisecondsSinceEpoch % 100000,
        title: "Appointment Removed",
        body:  "'$title' has been deleted.",
      );
      await fetchAppointments();
    } catch (e) {
      emit(AppointmentsError(
          AppErrorHandler.handle(e, context: "deleteAppointment")));
    }
  }

  // ─── Requests ─────────────────────────────────────────────────────────────

  Future<void> fetchRequests() async {
    emit(AppointmentsLoading());
    try {
      final requests = await _repo.getRequests();
      emit(RequestsLoaded(requests));
    } catch (e) {
      emit(AppointmentsError(
          AppErrorHandler.handle(e, context: "fetchRequests")));
    }
  }

  Future<void> sendRequest(AppointmentRequest req) async {
    try {
      await _repo.sendRequest(req);
      NotificationService().showNotification(
        id:    DateTime.now().millisecondsSinceEpoch % 100000,
        title: "Request Sent ✅",
        body:  "Your request '${req.title}' has been sent to the doctor.",
      );
      await fetchRequests();
    } catch (e) {
      emit(AppointmentsError(
          AppErrorHandler.handle(e, context: "sendRequest")));
    }
  }

  Future<void> acceptRequest(int id, {String notes = ""}) async {
    try {
      await _repo.acceptRequest(id, notes: notes);
      NotificationService().showNotification(
        id:    DateTime.now().millisecondsSinceEpoch % 100000,
        title: "Request Accepted ✅",
        body:  "Appointment has been created.",
      );
      emit(RequestActionSuccess("Request accepted. Appointment has been created."));
      await fetchRequests();
    } catch (e) {
      emit(AppointmentsError(
          AppErrorHandler.handle(e, context: "acceptRequest")));
    }
  }

  Future<void> rejectRequest(int id, {String doctorNote = ""}) async {
    try {
      await _repo.rejectRequest(id, doctorNote: doctorNote);
      NotificationService().showNotification(
        id:    DateTime.now().millisecondsSinceEpoch % 100000,
        title: "Request Rejected",
        body:  "The request has been rejected.",
      );
      emit(RequestActionSuccess("Request rejected."));
      await fetchRequests();
    } catch (e) {
      emit(AppointmentsError(
          AppErrorHandler.handle(e, context: "rejectRequest")));
    }
  }

  Future<void> suggestAlternative(
      int id, String suggestedDate, String note) async {
    try {
      await _repo.suggestAlternative(id, suggestedDate, note);
      NotificationService().showNotification(
        id:    DateTime.now().millisecondsSinceEpoch % 100000,
        title: "Alternative Suggested",
        body:  "Patient has been notified.",
      );
      emit(RequestActionSuccess("Alternative time suggested to patient."));
      await fetchRequests();
    } catch (e) {
      emit(AppointmentsError(
          AppErrorHandler.handle(e, context: "suggestAlternative")));
    }
  }

  Future<void> confirmSuggestion(int id) async {
    try {
      await _repo.confirmSuggestion(id);
      NotificationService().showNotification(
        id:    DateTime.now().millisecondsSinceEpoch % 100000,
        title: "Appointment Confirmed ✅",
        body:  "You confirmed the suggested time.",
      );
      emit(RequestActionSuccess(
          "Appointment confirmed! Check your appointments."));
      await fetchRequests();
    } catch (e) {
      emit(AppointmentsError(
          AppErrorHandler.handle(e, context: "confirmSuggestion")));
    }
  }

  // ✅ جديد — المريض يرفض اقتراح الطبيب
  Future<void> declineSuggestion(int id, {String patientNote = ""}) async {
    try {
      await _repo.declineSuggestion(id, patientNote: patientNote);
      NotificationService().showNotification(
        id:    DateTime.now().millisecondsSinceEpoch % 100000,
        title: "Suggestion Declined",
        body:  "You declined the suggested time. The doctor will be notified.",
      );
      emit(RequestActionSuccess("Suggestion declined. Doctor has been notified."));
      await fetchRequests();
    } catch (e) {
      emit(AppointmentsError(
          AppErrorHandler.handle(e, context: "declineSuggestion")));
    }
  }

  // ✅ جديد — مسح الطلبات المنجزة
  Future<void> clearCompletedRequests() async {
    try {
      await _repo.clearCompletedRequests();
      NotificationService().showNotification(
        id:    DateTime.now().millisecondsSinceEpoch % 100000,
        title: "Cleared",
        body:  "Completed requests have been removed.",
      );
      await fetchRequests();
    } catch (e) {
      emit(AppointmentsError(
          AppErrorHandler.handle(e, context: "clearCompletedRequests")));
    }
  }
}