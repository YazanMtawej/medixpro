import '../../domain/entities/patient.dart';
import '../../domain/repositories/patients_repository.dart';
import '../datasources/patients_remote_datasource.dart';

class PatientsRepositoryImpl implements PatientsRepository {
  final PatientsRemoteDataSource remote;
  const PatientsRepositoryImpl(this.remote);

  @override
  Future<List<Patient>> getPatients() => remote.getPatients();

  @override
  Future<void> addPatient(Patient patient) => remote.addPatient(patient);

  @override
  Future<void> updatePatient(int id, Patient patient) =>
      remote.updatePatient(id, patient);

  @override
  Future<void> deletePatient(int id) => remote.deletePatient(id);
}