import '../../domain/entities/medication.dart';
import '../../domain/repositories/medications_repository.dart';
import '../datasources/medications_remote_datasource.dart';

class MedicationsRepositoryImpl implements MedicationsRepository {
  final MedicationsRemoteDataSource remote;
  const MedicationsRepositoryImpl(this.remote);

  @override
  Future<List<Medication>> getMedications({int? patientId, String? search}) =>
      remote.getMedications(patientId: patientId, search: search);

  @override
  Future<List<CommonMedication>> getCommonMedications({String? search}) =>
      remote.getCommonMedications(search: search);

  @override
  Future<void> addMedication(Medication med) => remote.addMedication(med);

  @override
  Future<void> updateMedication(Medication med) => remote.updateMedication(med);

  @override
  Future<void> deleteMedication(int id) => remote.deleteMedication(id);
}