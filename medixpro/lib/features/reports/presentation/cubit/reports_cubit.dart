import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medixpro/core/notifications/notification_service.dart';
import '../../domain/entities/report.dart';
import '../../domain/usecases/get_reports_usecase.dart';
import '../../domain/usecases/add_report_usecase.dart';
import '../../domain/usecases/update_report_usecase.dart';
import '../../domain/usecases/delete_report_usecase.dart';
import 'reports_state.dart';

class ReportsCubit extends Cubit<ReportsState> {
  final GetReportsUseCase    _getReports;
  final AddReportUseCase     _addReport;
  final UpdateReportUseCase  _updateReport;
  final DeleteReportUseCase  _deleteReport;

  ReportsCubit(
    this._getReports,
    this._addReport,
    this._updateReport,
    this._deleteReport,
  ) : super(ReportsInitial());

  Future<void> fetchReports({
    int? patientId,
    String? status,
    String? search,
  }) async {
    emit(ReportsLoading());
    try {
      final reports = await _getReports(
          patientId: patientId, status: status, search: search);
      emit(ReportsLoaded(reports));
    } catch (_) {
      emit(ReportsError("Failed to load reports"));
    }
  }

  Future<void> createReport(Report report) async {
    try {
      await _addReport(report);
      await fetchReports();
      await NotificationService.instance.notifyReportCreated(report.title, report.patientName);
    } catch (_) {
      emit(ReportsError("Failed to create report"));
    }
  }

  Future<void> editReport(Report report) async {
    try {
      await _updateReport(report);
      await fetchReports();
    } catch (_) {
      emit(ReportsError("Failed to update report"));
    }
  }

  Future<void> removeReport(int id) async {
    try {
      await _deleteReport(id);
      await fetchReports();
    } catch (_) {
      emit(ReportsError("Failed to delete report"));
    }
  }
}