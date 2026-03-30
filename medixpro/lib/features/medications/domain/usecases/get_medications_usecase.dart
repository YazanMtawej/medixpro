import '../entities/medication.dart';
import '../repositories/medications_repository.dart';

class GetMedicationsUseCase {
  final MedicationsRepository repository;

  GetMedicationsUseCase(this.repository);

  Future<List<Medication>> call({int? patientId}) {
    return repository.getMedications(patientId: patientId);
  }
}