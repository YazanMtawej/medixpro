import '../entities/medication.dart';

abstract class MedicationsRepository {
  Future<List<Medication>> getMedications({int? patientId, String? search});
  Future<List<CommonMedication>> getCommonMedications({String? search});
  Future<void> addMedication(Medication med);
  Future<void> updateMedication(Medication med);
  Future<void> deleteMedication(int id);
}