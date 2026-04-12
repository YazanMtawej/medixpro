import '../repositories/patients_repository.dart';

class DeletePatientUseCase {
  final PatientsRepository repo;
  const DeletePatientUseCase(this.repo);
  Future<void> call(int id) => repo.deletePatient(id);
}