import '../entities/medication.dart';
import '../repositories/medications_repository.dart';

class GetMedicationsUseCase {
  final MedicationsRepository repository;
  const GetMedicationsUseCase(this.repository);

  Future<List<Medication>> call({int? patientId, String? search}) =>
      repository.getMedications(patientId: patientId, search: search);
}