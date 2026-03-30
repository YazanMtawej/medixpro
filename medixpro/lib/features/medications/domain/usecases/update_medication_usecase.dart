import '../entities/medication.dart';
import '../repositories/medications_repository.dart';

class UpdateMedicationUseCase {
  final MedicationsRepository repository;

  UpdateMedicationUseCase(this.repository);

  Future<void> call(Medication med) {
    return repository.updateMedication(med);
  }
}