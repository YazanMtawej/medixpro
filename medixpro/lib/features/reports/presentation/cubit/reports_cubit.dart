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

  final _notif = NotificationService();

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
    } catch (_) {
      emit(ReportsError("Failed to load reports"));
    }
  }

  Future<void> createReport(Report report) async {
    try {
      final title       = report.title.trim();
      final patientName = report.patientName.trim();

      await _addReport(report);

      await _notif.notifyReportCreated(
        title.isNotEmpty       ? title       : "Report",
        patientName.isNotEmpty ? patientName : "Patient",
      );

      await fetchReports();
    } catch (_) {
      emit(ReportsError("Failed to create report"));
    }
  }

  Future<void> editReport(Report report) async {
    try {
      final title = report.title.trim();

      await _updateReport(report);

      // إشعار خاص عند تحويل التقرير لـ final
      if (report.status == "final") {
        await _notif.notifyReportFinalized(
          title.isNotEmpty ? title : "Report",
        );
      }

      await fetchReports();
    } catch (_) {
      emit(ReportsError("Failed to update report"));
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
      await _notif.notifyReportDeleted(title);
      await fetchReports();
    } catch (_) {
      emit(ReportsError("Failed to delete report"));
    }
  }
}