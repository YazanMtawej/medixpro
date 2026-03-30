import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medixpro/features/reports/presentation/cubit/reports_state.dart';
import '../../domain/usecases/get_reports_usecase.dart';

class ReportsCubit extends Cubit<ReportsState> {
  final GetReportsUseCase getReportsUseCase;
  final AddReportUseCase addReportUseCase;

  ReportsCubit(this.getReportsUseCase, this.addReportUseCase) : super(ReportsInitial());

  /// ====== Fetch all reports ======
  Future<void> fetchReports() async {
    emit(ReportsLoading());
    try {
      final reports = await getReportsUseCase();
      emit(ReportsLoaded(reports));
    } catch (e) {
      emit(ReportsError("Failed to load reports: ${e.toString()}"));
    }
  }

  /// ====== Add a new report ======
  Future<void> createReport(Map<String, dynamic> data) async {
    emit(ReportsLoading());
    try {
      await addReportUseCase(data);
      // بعد إضافة التقرير، نعيد جلب القائمة لتحديث الواجهة
      final reports = await getReportsUseCase();
      emit(ReportsLoaded(reports));
    } catch (e) {
      emit(ReportsError("Failed to add report: ${e.toString()}"));
    }
  }

  /// ====== Optional: Refresh reports ======
  Future<void> refreshReports() async {
    await fetchReports();
  }
}