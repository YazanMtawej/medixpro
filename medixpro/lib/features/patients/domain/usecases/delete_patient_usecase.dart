import 'package:medixpro/features/patients/data/repositories_impl/patients_repository_impl.dart';

class DeletePatientUseCase {
  final PatientsRepositoryImpl repo;

  DeletePatientUseCase(this.repo);

  Future<void> call(int id) {
    return repo.deletePatient(id);
  }
}