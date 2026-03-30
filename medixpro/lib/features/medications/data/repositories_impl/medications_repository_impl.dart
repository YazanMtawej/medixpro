import '../../domain/entities/medication.dart';
import '../../domain/repositories/medications_repository.dart';
import '../datasources/medications_remote_datasource.dart';

class MedicationsRepositoryImpl implements MedicationsRepository {
  final MedicationsRemoteDataSource remote;

  MedicationsRepositoryImpl(this.remote);

  @override
  Future<List<Medication>> getMedications({int? patientId}) {
    return remote.getMedications(patientId: patientId);
  }

  @override
  Future<void> addMedication(Medication med) {
    return remote.addMedication(med);
  }

  @override
  Future<void> updateMedication(Medication med) {
    return remote.updateMedication(med);
  }

  @override
  Future<void> deleteMedication(int id) {
    return remote.deleteMedication(id);
  }
}