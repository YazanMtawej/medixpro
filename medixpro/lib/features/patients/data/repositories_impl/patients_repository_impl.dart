import '../../domain/entities/patient.dart';
import '../../domain/repositories/patients_repository.dart';
import '../datasources/patients_remote_datasource.dart';

class PatientsRepositoryImpl implements PatientsRepository {

  final PatientsRemoteDataSource remote;

  PatientsRepositoryImpl(this.remote);

  @override
  Future<List<Patient>> getPatients() {
    return remote.getPatients();
  }

  @override
  Future<void> addPatient(Patient patient) {
    return remote.addPatient(patient);
  }

  @override
  Future<void> updatePatient(int id, Patient patient) {
    return remote.updatePatient(id, patient);
  }
  Future<void> deletePatient(int id) {
  return remote.deletePatient(id);
}
}