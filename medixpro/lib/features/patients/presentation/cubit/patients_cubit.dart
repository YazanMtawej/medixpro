import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medixpro/core/notifications/notification_service.dart';
import '../../domain/entities/patient.dart';
import '../../domain/usecases/get_patients_usecase.dart';
import '../../domain/usecases/add_patient_usecase.dart';
import '../../domain/usecases/update_patient_usecase.dart';
import '../../domain/usecases/delete_patient_usecase.dart';
import 'patients_state.dart';

class PatientsCubit extends Cubit<PatientsState> {
  final GetPatientsUseCase   _getPatients;
  final AddPatientUseCase    _addPatient;
  final UpdatePatientUseCase _updatePatient;
  final DeletePatientUseCase _deletePatient;

  final _notif = NotificationService();

  PatientsCubit(
    this._getPatients,
    this._addPatient,
    this._updatePatient,
    this._deletePatient,
  ) : super(PatientsInitial());

  Future<void> loadPatients() async {
    emit(PatientsLoading());
    try {
      final patients = await _getPatients();
      emit(PatientsLoaded(patients));
    } catch (_) {
      emit(PatientsError("Failed to load patients"));
    }
  }

  Future<void> addPatient(Patient patient) async {
    try {
      // ✅ احفظ الاسم قبل أي عملية
      final name = patient.name.trim();

      await _addPatient(patient);

      // ✅ الإشعار قبل reload لضمان ظهوره
      await _notif.notifyPatientAdded(name.isNotEmpty ? name : "New Patient");

      await loadPatients();
    } catch (_) {
      emit(PatientsError("Failed to add patient"));
    }
  }

  Future<void> updatePatient(int id, Patient patient) async {
    try {
      await _updatePatient(id, patient);
      await loadPatients();
    } catch (_) {
      emit(PatientsError("Failed to update patient"));
    }
  }

  Future<void> deletePatient(int id) async {
    // ✅ احفظ الاسم من الـ state الحالي قبل الحذف
    String name = "Patient";
    final current = state;
    if (current is PatientsLoaded) {
      try {
        name = current.patients.firstWhere((p) => p.id == id).name;
      } catch (_) {}
    }

    try {
      await _deletePatient(id);
      await _notif.notifyPatientDeleted(name);
      await loadPatients();
    } catch (_) {
      emit(PatientsError("Failed to delete patient"));
    }
  }
}