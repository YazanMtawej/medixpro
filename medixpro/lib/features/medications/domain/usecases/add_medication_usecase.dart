import '../entities/medication.dart';
import '../repositories/medications_repository.dart';

class AddMedicationUseCase {
  final MedicationsRepository repository;

  AddMedicationUseCase(this.repository);

  Future<void> call(Medication med) {
    return repository.addMedication(med);
  }
}