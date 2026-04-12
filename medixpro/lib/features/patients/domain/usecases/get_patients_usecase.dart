import '../entities/patient.dart';
import '../repositories/patients_repository.dart';

class GetPatientsUseCase {
  final PatientsRepository repo;
  const GetPatientsUseCase(this.repo);
  Future<List<Patient>> call() => repo.getPatients();
}