import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/patient.dart';
import '../../domain/usecases/get_patients_usecase.dart';
import '../../domain/usecases/add_patient_usecase.dart';
import '../../domain/usecases/update_patient_usecase.dart';
import '../../domain/usecases/delete_patient_usecase.dart';
import 'patients_state.dart';

class PatientsCubit extends Cubit<PatientsState> {
  final GetPatientsUseCase _getPatients;
  final AddPatientUseCase _addPatient;
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
      emit(PatientsError("Failed to load patients"));
    }
  }

  Future<void> addPatient(Patient patient) async {
    try {
      await _addPatient(patient);
      await loadPatients();
    } catch (e) {
      emit(PatientsError("Failed to add patient"));
    }
  }

  Future<void> updatePatient(int id, Patient patient) async {
    try {
      await _updatePatient(id, patient);
      await loadPatients();
    } catch (e) {
      emit(PatientsError("Failed to update patient"));
    }
  }

  Future<void> deletePatient(int id) async {
    try {
      await _deletePatient(id);
      await loadPatients();
    } catch (e) {
      emit(PatientsError("Failed to delete patient"));
    }
  }
}