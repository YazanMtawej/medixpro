import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medixpro/core/errors/app_error_handler.dart';
import 'package:medixpro/core/notifications/notification_service.dart';
import '../../domain/entities/medication.dart';
import '../../domain/usecases/get_medications_usecase.dart';
import '../../domain/usecases/add_medication_usecase.dart';
import '../../domain/usecases/update_medication_usecase.dart';
import '../../domain/usecases/delete_medication_usecase.dart';
import '../../domain/usecases/get_common_medications_usecase.dart';

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
  final GetMedicationsUseCase _getMedications;
  final AddMedicationUseCase _addMedication;
  final UpdateMedicationUseCase _updateMedication;
  final DeleteMedicationUseCase _deleteMedication;
  final GetCommonMedicationsUseCase _getCommonMedications; // ← ADD

  MedicationsCubit(
    this._getMedications,
    this._addMedication,
    this._updateMedication,
    this._deleteMedication,
    this._getCommonMedications, // ← ADD
  ) : super(MedicationsInitial());

  Future<List<CommonMedication>> fetchCommonMedications({String? search}) =>
      _getCommonMedications(search: search);

  Future<void> fetchMedications({int? patientId, String? search}) async {
    emit(MedicationsLoading());
    try {
      final meds = await _getMedications(patientId: patientId, search: search);
      emit(MedicationsLoaded(meds));
    } catch (e) {
      emit(
        MedicationsError(
          AppErrorHandler.handle(e, context: "fetchMedications"),
        ),
      );
    }
  }

  Future<void> addNewMedication(Medication med) async {
    final name = med.name.trim().isNotEmpty ? med.name.trim() : "Medication";
    final patientName = med.patientName.trim().isNotEmpty
        ? med.patientName.trim()
        : "Patient";
    try {
      await _addMedication(med);
      NotificationService().showNotification(
        id: DateTime.now().millisecondsSinceEpoch % 100000,
        title: "Prescription Added",
        body: "$name prescribed to $patientName.",
      );
      await fetchMedications();
    } catch (e) {
      emit(
        MedicationsError(AppErrorHandler.handle(e, context: "addMedication")),
      );
    }
  }

  Future<void> updateExistingMedication(Medication med) async {
    try {
      await _updateMedication(med);
      NotificationService().showNotification(
        id: DateTime.now().millisecondsSinceEpoch % 100000,
        title: "Prescription Updated",
        body: "Medication '${med.name}' has been updated.",
      );
      await fetchMedications();
    } catch (e) {
      emit(
        MedicationsError(
          AppErrorHandler.handle(e, context: "updateMedication"),
        ),
      );
    }
  }

  Future<void> deleteExistingMedication(int id) async {
    String name = "Medication";
    final cur = state;
    if (cur is MedicationsLoaded) {
      try {
        name = cur.medications.firstWhere((m) => m.id == id).name;
      } catch (_) {}
    }
    try {
      await _deleteMedication(id);
      NotificationService().showNotification(
        id: DateTime.now().millisecondsSinceEpoch % 100000,
        title: "Prescription Removed",
        body: "Medication '$name' has been deleted.",
      );
      await fetchMedications();
    } catch (e) {
      emit(
        MedicationsError(
          AppErrorHandler.handle(e, context: "deleteMedication"),
        ),
      );
    }
  }
}
