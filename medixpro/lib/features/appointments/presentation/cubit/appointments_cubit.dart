import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/usecases/add_appointment_usecase.dart';
import '../../domain/usecases/get_appointments_usecase.dart';
import '../../domain/usecases/update_appointment_usecase.dart';

part 'appointments_state.dart';

class AppointmentsCubit extends Cubit<AppointmentsState> {
  final GetAppointmentsUseCase getAppointments;
  final AddAppointmentUseCase addAppointment;
  final UpdateAppointmentUseCase updateAppointment;

  AppointmentsCubit(this.getAppointments, this.addAppointment, this.updateAppointment)
      : super(AppointmentsInitial());

  Future<void> fetchAppointments() async {
    emit(AppointmentsLoading());
    try {
      final data = await getAppointments();
      emit(AppointmentsLoaded(data));
    } catch (e) {
      emit(AppointmentsError(e.toString()));
    }
  }

  Future<void> addNewAppointment(Appointment appointment) async {
    try {
      await addAppointment(appointment);
      await fetchAppointments();
    } catch (e) {
      emit(AppointmentsError(e.toString()));
    }
  }

  Future<void> editAppointment(Appointment appointment) async {
    try {
      await updateAppointment(appointment);
      await fetchAppointments();
    } catch (e) {
      emit(AppointmentsError(e.toString()));
    }
  }
}