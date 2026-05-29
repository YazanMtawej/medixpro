import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_dashboard_stats_usecase.dart';
import '../../domain/usecases/get_today_appointments_usecase.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final GetDashboardStatsUseCase _getStats;
  final GetTodayAppointmentsUseCase _getAppointments;

  Timer? _timer;
  bool _isLoading = false;

  DashboardCubit(this._getStats, this._getAppointments)
      : super(DashboardInitial()) {
    _startAutoRefresh();
  }

  // 🔥 تحميل البيانات الأساسي
 Future<void> loadDashboard() async {
  if (_isLoading || isClosed) return;        // ← early exit if already closed

  _isLoading = true;

  try {
    final stats        = await _getStats();
    final appointments = await _getAppointments();

    if (!isClosed) {                         // ← guard before emit
      emit(DashboardLoaded(stats, appointments));
    }
  } catch (_) {
    if (!isClosed) {                         // ← guard before emit
      emit(DashboardError("Failed to load dashboard"));
    }
  } finally {
    _isLoading = false;
  }
}

  // 🔥 تشغيل التحديث التلقائي كل 30 ثانية
  void _startAutoRefresh() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 45), (timer) {
      loadDashboard();
    });
  }

  // 🔥 إيقاف التايمر عند إغلاق الـ Cubit (مهم جداً لتجنب memory leak)
  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}