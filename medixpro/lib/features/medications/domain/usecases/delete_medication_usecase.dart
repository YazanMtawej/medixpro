import '../repositories/medications_repository.dart';

class DeleteMedicationUseCase {
  final MedicationsRepository repository;
  const DeleteMedicationUseCase(this.repository);
  Future<void> call(int id) => repository.deleteMedication(id);
}