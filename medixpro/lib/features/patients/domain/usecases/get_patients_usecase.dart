import '../entities/patient.dart';
import '../repositories/patients_repository.dart';

class GetPatientsUseCase {

  final PatientsRepository repo;

  GetPatientsUseCase(this.repo);

  Future<List<Patient>> call() {
    return repo.getPatients();
  }
}