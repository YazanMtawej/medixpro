import '../repositories/medications_repository.dart';

class DeleteMedicationUseCase {
  final MedicationsRepository repository;

  DeleteMedicationUseCase(this.repository);

  Future<void> call(int id) {
    return repository.deleteMedication(id);
  }
}