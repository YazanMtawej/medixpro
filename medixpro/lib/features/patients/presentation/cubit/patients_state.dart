import '../../domain/entities/patient.dart';

abstract class PatientsState {}

class PatientsInitial extends PatientsState {}

class PatientsLoading extends PatientsState {}

class PatientsLoaded extends PatientsState {
  final List<Patient> patients;
  PatientsLoaded(this.patients);
}

class PatientsError extends PatientsState {
  final String message;
  PatientsError(this.message);
}