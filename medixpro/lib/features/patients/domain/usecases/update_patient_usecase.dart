import '../entities/patient.dart';
import '../repositories/patients_repository.dart';

class UpdatePatientUseCase {
  final PatientsRepository repo;
  const UpdatePatientUseCase(this.repo);
  Future<void> call(int id, Patient patient) => repo.updatePatient(id, patient);
}