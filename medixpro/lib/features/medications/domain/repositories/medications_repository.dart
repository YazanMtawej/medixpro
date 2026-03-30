import '../entities/medication.dart';

abstract class MedicationsRepository {
  Future<List<Medication>> getMedications({int? patientId});
  Future<void> addMedication(Medication medication);
  Future<void> updateMedication(Medication medication);
  Future<void> deleteMedication(int id);
}