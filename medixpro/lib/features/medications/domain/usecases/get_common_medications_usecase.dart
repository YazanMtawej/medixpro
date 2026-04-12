import '../entities/medication.dart';
import '../repositories/medications_repository.dart';

class GetCommonMedicationsUseCase {
  final MedicationsRepository repository;
  const GetCommonMedicationsUseCase(this.repository);

  Future<List<CommonMedication>> call({String? search}) =>
      repository.getCommonMedications(search: search);
}