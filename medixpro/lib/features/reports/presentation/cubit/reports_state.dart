import '../../domain/entities/report.dart';

abstract class ReportsState {}

class ReportsInitial extends ReportsState {}

class ReportsLoading extends ReportsState {}

class ReportsLoaded extends ReportsState {
  final List<Report> reports;
  ReportsLoaded(this.reports);
}

class ReportsError extends ReportsState {
  final String message;
  ReportsError(this.message);
}