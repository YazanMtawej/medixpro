import '../entities/patient.dart';
import '../repositories/patients_repository.dart';

class AddPatientUseCase {
  final PatientsRepository repo;
  const AddPatientUseCase(this.repo);
  Future<void> call(Patient patient) => repo.addPatient(patient);
}