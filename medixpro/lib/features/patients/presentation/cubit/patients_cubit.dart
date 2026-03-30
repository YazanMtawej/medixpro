import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medixpro/features/patients/domain/usecases/delete_patient_usecase.dart';

import '../../domain/entities/patient.dart';
import '../../domain/usecases/get_patients_usecase.dart';
import '../../domain/usecases/add_patient_usecase.dart';
import '../../domain/usecases/update_patient_usecase.dart';

import 'patients_state.dart';

class PatientsCubit extends Cubit<PatientsState> {

  final GetPatientsUseCase getPatientsUseCase;
  final AddPatientUseCase addPatientUseCase;
  final UpdatePatientUseCase updatePatientUseCase;
 final DeletePatientUseCase deletePatientUseCase;
 
  PatientsCubit(
      this.getPatientsUseCase,
      this.addPatientUseCase,
      this.updatePatientUseCase, this.deletePatientUseCase,
      ) : super(PatientsInitial());

  Future<void> loadPatients() async {

    emit(PatientsLoading());

    try {

      final patients = await getPatientsUseCase();

      emit(PatientsLoaded(patients));

    } catch (e) {

      emit(PatientsError("Failed to load patients"));
    }
  }

  Future<void> addPatient(Patient patient) async {

    await addPatientUseCase(patient);

    await loadPatients();
  }

  Future<void> updatePatient(int id, Patient patient) async {

    await updatePatientUseCase(id, patient);

    await loadPatients();
  }

  Future<void> deletePatient(int id) async {
    await deletePatientUseCase(id);

    await loadPatients();
  }
  
}