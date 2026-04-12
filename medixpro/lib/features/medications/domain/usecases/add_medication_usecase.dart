import '../entities/medication.dart';
import '../repositories/medications_repository.dart';

class AddMedicationUseCase {
  final MedicationsRepository repository;
  const AddMedicationUseCase(this.repository);
  Future<void> call(Medication med) => repository.addMedication(med);
}