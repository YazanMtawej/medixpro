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
    } catch (e) {
      emit(PatientsError("Failed to load patients: $e"));
    }
  }

  Future<void> addPatient(Patient patient) async {
    // ✅ احفظ الاسم فوراً قبل أي عملية async
    final String name = patient.name.trim().isNotEmpty
        ? patient.name.trim()
        : "New Patient";

    try {
      await _addPatient(patient);

      // ✅ الإشعار منفصل عن الـ try حتى لا يُخفى فشله
      NotificationService().showNotification(
        id: DateTime.now().millisecondsSinceEpoch % 100000,
        title: "New Patient Registered",
        body: "Patient '$name' has been added successfully.",
      );

      await loadPatients();
    } catch (e) {
      emit(PatientsError("Failed to add patient: $e"));
    }
  }

  Future<void> updatePatient(int id, Patient patient) async {
    try {
      await _updatePatient(id, patient);

      NotificationService().showNotification(
        id: DateTime.now().millisecondsSinceEpoch % 100000,
        title: "Patient Updated",
        body: "Patient '${patient.name}' has been updated.",
      );

      await loadPatients();
    } catch (e) {
      emit(PatientsError("Failed to update patient: $e"));
    }
  }

  Future<void> deletePatient(int id) async {
    String name = "Patient";
    final current = state;
    if (current is PatientsLoaded) {
      try {
        name = current.patients.firstWhere((p) => p.id == id).name;
      } catch (_) {}
    }

    try {
      await _deletePatient(id);

      NotificationService().showNotification(
        id: DateTime.now().millisecondsSinceEpoch % 100000,
        title: "Patient Removed",
        body: "Patient '$name' and all related records were deleted.",
      );

      await loadPatients();
    } catch (e) {
      emit(PatientsError("Failed to delete patient: $e"));
    }
  }
}