import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medixpro/features/appointments/presentation/cubit/appointments_state.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/usecases/get_appointments_usecase.dart';
import '../../domain/usecases/add_appointment_usecase.dart';
import '../../domain/usecases/update_appointment_usecase.dart';
import '../../domain/usecases/delete_appointment_usecase.dart';


class AppointmentsCubit extends Cubit<AppointmentsState> {
  final GetAppointmentsUseCase _getAppointments;
  final AddAppointmentUseCase _addAppointment;
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
          patientId: patientId, status: status, search: search);
      emit(AppointmentsLoaded(data));
    } catch (_) {
      emit(AppointmentsError("Failed to load appointments"));
    }
  }

  Future<void> addNewAppointment(Appointment a) async {
    try {
      await _addAppointment(a);
      await fetchAppointments();
    } catch (_) {
      emit(AppointmentsError("Failed to add appointment"));
    }
  }

  Future<void> editAppointment(Appointment a) async {
    try {
      await _updateAppointment(a);
      await fetchAppointments();
    } catch (_) {
      emit(AppointmentsError("Failed to update appointment"));
    }
  }

  Future<void> deleteAppointment(int id) async {
    try {
      await _deleteAppointment(id);
      await fetchAppointments();
    } catch (_) {
      emit(AppointmentsError("Failed to delete appointment"));
    }
  }
}