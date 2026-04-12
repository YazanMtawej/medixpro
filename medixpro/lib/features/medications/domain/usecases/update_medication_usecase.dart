import '../entities/medication.dart';
import '../repositories/medications_repository.dart';

class UpdateMedicationUseCase {
  final MedicationsRepository repository;
  const UpdateMedicationUseCase(this.repository);
  Future<void> call(Medication med) => repository.updateMedication(med);
}