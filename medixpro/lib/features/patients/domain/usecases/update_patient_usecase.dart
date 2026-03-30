import '../entities/patient.dart';
import '../repositories/patients_repository.dart';

class UpdatePatientUseCase {

  final PatientsRepository repo;

  UpdatePatientUseCase(this.repo);

  Future<void> call(int id, Patient patient) {
    return repo.updatePatient(id, patient);
  }
}