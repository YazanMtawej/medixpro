import '../entities/patient.dart';
import '../repositories/patients_repository.dart';

class AddPatientUseCase {

  final PatientsRepository repo;

  AddPatientUseCase(this.repo);

  Future<void> call(Patient patient) {
    return repo.addPatient(patient);
  }
}