import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/medication.dart';
import '../../domain/usecases/get_medications_usecase.dart';
import '../../domain/usecases/add_medication_usecase.dart';
import '../../domain/usecases/update_medication_usecase.dart';
import '../../domain/usecases/delete_medication_usecase.dart';

abstract class MedicationsState {}

class MedicationsInitial extends MedicationsState {}

class MedicationsLoading extends MedicationsState {}

class MedicationsLoaded extends MedicationsState {
  final List<Medication> medications;
  MedicationsLoaded(this.medications);
}

class MedicationsError extends MedicationsState {
  final String message;
  MedicationsError(this.message);
}

class MedicationsCubit extends Cubit<MedicationsState> {
  final GetMedicationsUseCase getMedications;
  final AddMedicationUseCase addMedication;
  final UpdateMedicationUseCase updateMedication;
  final DeleteMedicationUseCase deleteMedication;

  MedicationsCubit(
    this.getMedications,
    this.addMedication,
    this.updateMedication,
    this.deleteMedication,
  ) : super(MedicationsInitial());

  Future<void> fetchMedications({int? patientId}) async {
    try {
      emit(MedicationsLoading());
      final meds = await getMedications(patientId: patientId);
      emit(MedicationsLoaded(meds));
    } catch (e) {
      emit(MedicationsError("Failed to load medications"));
    }
  }

  Future<void> addNewMedication(Medication med) async {
    await addMedication(med);
    await fetchMedications();
  }

  Future<void> updateExistingMedication(Medication med) async {
    await updateMedication(med);
    await fetchMedications();
  }

  Future<void> deleteExistingMedication(int id) async {
    await deleteMedication(id);
    await fetchMedications();
  }
}