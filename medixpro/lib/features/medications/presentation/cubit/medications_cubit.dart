import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medixpro/core/notifications/notification_service.dart';
import '../../domain/entities/medication.dart';
import '../../domain/usecases/get_medications_usecase.dart';
import '../../domain/usecases/add_medication_usecase.dart';
import '../../domain/usecases/update_medication_usecase.dart';
import '../../domain/usecases/delete_medication_usecase.dart';

// ─── States ───────────────────────────────────────────────────────────────────
abstract class MedicationsState {}
class MedicationsInitial extends MedicationsState {}
class MedicationsLoading  extends MedicationsState {}
class MedicationsLoaded   extends MedicationsState {
  final List<Medication> medications;
  MedicationsLoaded(this.medications);
}
class MedicationsError extends MedicationsState {
  final String message;
  MedicationsError(this.message);
}

// ─── Cubit ────────────────────────────────────────────────────────────────────
class MedicationsCubit extends Cubit<MedicationsState> {
  final GetMedicationsUseCase   _getMedications;
  final AddMedicationUseCase    _addMedication;
  final UpdateMedicationUseCase _updateMedication;
  final DeleteMedicationUseCase _deleteMedication;

  final _notif = NotificationService();

  MedicationsCubit(
    this._getMedications,
    this._addMedication,
    this._updateMedication,
    this._deleteMedication,
  ) : super(MedicationsInitial());

  Future<void> fetchMedications({int? patientId, String? search}) async {
    emit(MedicationsLoading());
    try {
      final meds = await _getMedications(patientId: patientId, search: search);
      emit(MedicationsLoaded(meds));
    } catch (_) {
      emit(MedicationsError("Failed to load medications"));
    }
  }

  Future<void> addNewMedication(Medication med) async {
    try {
      final name        = med.name.trim();
      final patientName = med.patientName.trim();

      await _addMedication(med);

      await _notif.notifyMedicationAdded(
        name.isNotEmpty        ? name        : "Medication",
        patientName.isNotEmpty ? patientName : "Patient",
      );

      await fetchMedications();
    } catch (_) {
      emit(MedicationsError("Failed to add medication"));
    }
  }

  Future<void> updateExistingMedication(Medication med) async {
    try {
      await _updateMedication(med);
      await fetchMedications();
    } catch (_) {
      emit(MedicationsError("Failed to update medication"));
    }
  }

  Future<void> deleteExistingMedication(int id) async {
    String name = "Medication";
    final current = state;
    if (current is MedicationsLoaded) {
      try {
        name = current.medications.firstWhere((m) => m.id == id).name;
      } catch (_) {}
    }

    try {
      await _deleteMedication(id);
      await _notif.notifyMedicationDeleted(name);
      await fetchMedications();
    } catch (_) {
      emit(MedicationsError("Failed to delete medication"));
    }
  }
}