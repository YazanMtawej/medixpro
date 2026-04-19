import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medixpro/core/errors/app_error_handler.dart';
import 'package:medixpro/core/notifications/notification_service.dart';
import '../../domain/entities/report.dart';
import '../../domain/usecases/get_reports_usecase.dart';
import '../../domain/usecases/add_report_usecase.dart';
import '../../domain/usecases/update_report_usecase.dart';
import '../../domain/usecases/delete_report_usecase.dart';
import 'reports_state.dart';

class ReportsCubit extends Cubit<ReportsState> {
  final GetReportsUseCase   _getReports;
  final AddReportUseCase    _addReport;
  final UpdateReportUseCase _updateReport;
  final DeleteReportUseCase _deleteReport;

  ReportsCubit(this._getReports, this._addReport, this._updateReport, this._deleteReport)
      : super(ReportsInitial());

  Future<void> fetchReports({int? patientId, String? status, String? search}) async {
    emit(ReportsLoading());
    try {
      final reports = await _getReports(patientId: patientId, status: status, search: search);
      emit(ReportsLoaded(reports));
    } catch (e) {
      emit(ReportsError(AppErrorHandler.handle(e, context: "fetchReports")));
    }
  }

  Future<void> createReport(Report report) async {
    final title       = report.title.trim().isNotEmpty       ? report.title.trim()       : "Report";
    final patientName = report.patientName.trim().isNotEmpty ? report.patientName.trim() : "Patient";
    try {
      await _addReport(report);
      NotificationService().showNotification(
        id: DateTime.now().millisecondsSinceEpoch % 100000,
        title: "Report Created",
        body: "Medical report '$title' for $patientName is ready.",
      );
      await fetchReports();
    } catch (e) {
      emit(ReportsError(AppErrorHandler.handle(e, context: "createReport")));
    }
  }

  Future<void> editReport(Report report) async {
    final title = report.title.trim().isNotEmpty ? report.title.trim() : "Report";
    try {
      await _updateReport(report);
      final isFinal = report.status == "final";
      NotificationService().showNotification(
        id: DateTime.now().millisecondsSinceEpoch % 100000,
        title: isFinal ? "Report Finalized ✅" : "Report Updated",
        body: isFinal
            ? "Report '$title' has been marked as final."
            : "Report '$title' has been updated.",
      );
      await fetchReports();
    } catch (e) {
      emit(ReportsError(AppErrorHandler.handle(e, context: "editReport")));
    }
  }

  Future<void> removeReport(int id) async {
    String title = "Report";
    final cur    = state;
    if (cur is ReportsLoaded) {
      try { title = cur.reports.firstWhere((r) => r.id == id).title; } catch (_) {}
    }
    try {
      await _deleteReport(id);
      NotificationService().showNotification(
        id: DateTime.now().millisecondsSinceEpoch % 100000,
        title: "Report Deleted",
        body: "Report '$title' has been permanently deleted.",
      );
      await fetchReports();
    } catch (e) {
      emit(ReportsError(AppErrorHandler.handle(e, context: "removeReport")));
    }
  }
}