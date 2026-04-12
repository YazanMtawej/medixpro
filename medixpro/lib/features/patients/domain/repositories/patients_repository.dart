import '../entities/patient.dart';

abstract class PatientsRepository {
  Future<List<Patient>> getPatients();
  Future<void> addPatient(Patient patient);
  Future<void> updatePatient(int id, Patient patient);
  Future<void> deletePatient(int id);
}