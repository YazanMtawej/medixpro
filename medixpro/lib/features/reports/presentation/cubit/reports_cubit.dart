import 'package:flutter_bloc/flutter_bloc.dart';
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
        patientId: patientId,
        status: status,
        search: search,
      );
      emit(ReportsLoaded(reports));
    } catch (e) {
      emit(ReportsError("Failed to load reports: $e"));
    }
  }

  Future<void> createReport(Report report) async {
    final String title       = report.title.trim().isNotEmpty       ? report.title.trim()       : "Report";
    final String patientName = report.patientName.trim().isNotEmpty ? report.patientName.trim() : "Patient";

    try {
      await _addReport(report);

      NotificationService().showNotification(
        id: DateTime.now().millisecondsSinceEpoch % 100000,
        title: "Report Created",
        body: "Medical report '$title' for $patientName is ready.",
      );

      await fetchReports();
    } catch (e) {
      emit(ReportsError("Failed to create report: $e"));
    }
  }

  Future<void> editReport(Report report) async {
    final String title = report.title.trim().isNotEmpty ? report.title.trim() : "Report";

    try {
      await _updateReport(report);

      final String notifTitle = report.status == "final"
          ? "Report Finalized ✅"
          : "Report Updated";
      final String notifBody = report.status == "final"
          ? "Report '$title' has been marked as final."
          : "Report '$title' has been updated.";

      NotificationService().showNotification(
        id: DateTime.now().millisecondsSinceEpoch % 100000,
        title: notifTitle,
        body: notifBody,
      );

      await fetchReports();
    } catch (e) {
      emit(ReportsError("Failed to update report: $e"));
    }
  }

  Future<void> removeReport(int id) async {
    String title = "Report";
    final current = state;
    if (current is ReportsLoaded) {
      try {
        title = current.reports.firstWhere((r) => r.id == id).title;
      } catch (_) {}
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
      emit(ReportsError("Failed to delete report: $e"));
    }
  }
}