import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medixpro/core/network/api_client.dart';
import 'package:medixpro/l10n/app_localizations.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../clinic_map/data/clinic_location_datasource.dart';
import '../../../clinic_map/presentation/clinic_map_page.dart';
import '../../domain/entities/appointment_request.dart';
import '../appointment_l10n.dart';
import '../cubit/appointments_cubit.dart';
import '../cubit/appointments_state.dart';

class DoctorRequestsPage extends StatefulWidget {
  const DoctorRequestsPage({super.key});

  @override
  State<DoctorRequestsPage> createState() => _DoctorRequestsPageState();
}

class _DoctorRequestsPageState extends State<DoctorRequestsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    Future.microtask(() => context.read<AppointmentsCubit>().fetchRequests());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontSize: 13)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<AppointmentsCubit, AppointmentsState>(
      listener: (context, state) {
        if (state is RequestActionSuccess) {
          _showSnack(state.message, AppColors.success);
        } else if (state is AppointmentsError) {
          _showSnack(state.message, AppColors.error);
        }
      },
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.lightBackground,
        body: SafeArea(
          child: Column(
            children: [
              _Header(isDark: isDark),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: AppColors.primary,
                  labelColor: AppColors.primary,
                  unselectedLabelColor:
                      isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  tabs: [
                    Tab(text: AppLocalizations.of(context).statusPending),
                    Tab(text: AppLocalizations.of(context).tabSuggested),
                    Tab(text: AppLocalizations.of(context).tabDone),
                  ],
                ),
              ),
              Expanded(
                child: BlocBuilder<AppointmentsCubit, AppointmentsState>(
                  builder: (context, state) {
                    if (state is AppointmentsLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is RequestsLoaded) {
                      final pending   = state.requests.where((r) => r.isPending).toList();
                      final suggested = state.requests.where((r) => r.isSuggested).toList();
                      final done      = state.requests.where((r) => r.isAccepted || r.isRejected).toList();

                      return TabBarView(
                        controller: _tabController,
                        children: [
                          _RequestList(
                            data: pending,
                            isDark: isDark,
                            showActions: true,
                          ),
                          _RequestList(
                            data: suggested,
                            isDark: isDark,
                            showActions: false,
                          ),
                          _RequestList(
                            data: done,
                            isDark: isDark,
                            showActions: false,
                          ),
                        ],
                      );
                    }

                    return Center(child: Text(AppLocalizations.of(context).pullToRefresh));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final bool isDark;
  const _Header({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark ? AppColors.gradientDark : AppColors.gradientLight,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.inbox_rounded, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context).appointmentRequests,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(AppLocalizations.of(context).reviewRespondRequests,
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── List ─────────────────────────────────────────────────────────────────────
class _RequestList extends StatelessWidget {
  final List<AppointmentRequest> data;
  final bool isDark;
  final bool showActions;

  const _RequestList({
    required this.data,
    required this.isDark,
    required this.showActions,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.inbox_outlined,
                  size: 44, color: AppColors.primary),
            ),
            const SizedBox(height: 14),
            Text(
              AppLocalizations.of(context).nothingHereYet,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<AppointmentsCubit>().fetchRequests(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        itemCount: data.length,
        itemBuilder: (context, i) {
          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 250 + (i * 60)),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (_, v, child) => Opacity(
              opacity: v,
              child: Transform.translate(
                  offset: Offset(0, 16 * (1 - v)), child: child),
            ),
            child: _RequestCard(
              request:     data[i],
              isDark:      isDark,
              showActions: showActions,
            ),
          );
        },
      ),
    );
  }
}

// ─── Request Card ─────────────────────────────────────────────────────────────
class _RequestCard extends StatelessWidget {
  final AppointmentRequest request;
  final bool isDark;
  final bool showActions;

  const _RequestCard({
    required this.request,
    required this.isDark,
    required this.showActions,
  });

  Color get _statusColor {
    switch (request.status) {
      case "accepted":  return AppColors.success;
      case "rejected":  return AppColors.error;
      case "suggested": return AppColors.warning;
      default:          return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 0.8,
        ),
        boxShadow: isDark
            ? []
            : [BoxShadow(
                blurRadius: 10,
                offset: const Offset(0, 3),
                color: Colors.black.withOpacity(0.05))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Row(
          children: [
            // Accent bar
            Container(width: 4, color: _statusColor),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header ────────────────────────────────────────────
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.person_outline,
                              color: _statusColor, size: 16),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                request.patientName.isNotEmpty
                                    ? request.patientName
                                    : request.requestedByName,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTextPrimary,
                                ),
                              ),
                              Text(
                                request.title,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            appointmentRequestStatusLabel(
                                    context, request.status)
                                .toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: _statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),
                    const Divider(height: 1),
                    const SizedBox(height: 10),

                    // ── Info ──────────────────────────────────────────────
                    _InfoRow(
                      icon: Icons.calendar_month_outlined,
                      label: AppLocalizations.of(context).requested,
                      value: _fmt(request.preferredDate),
                      color: AppColors.primary,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 4),
                    _InfoRow(
                      icon: Icons.medical_services_outlined,
                      label: AppLocalizations.of(context).typeLabel,
                      value: appointmentTypeLabel(context, request.type),
                      isDark: isDark,
                    ),
                    if (request.reason.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      _InfoRow(
                        icon: Icons.notes_outlined,
                        label: AppLocalizations.of(context).reason,
                        value: request.reason,
                        isDark: isDark,
                      ),
                    ],
                    if (request.symptoms.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      _InfoRow(
                        icon: Icons.sick_outlined,
                        label: AppLocalizations.of(context).symptoms,
                        value: request.symptoms,
                        isDark: isDark,
                      ),
                    ],

                    // ── Suggested Date ────────────────────────────────────
                    if (request.isSuggested && request.suggestedDate != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: AppColors.warning.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.schedule_outlined,
                                size: 15, color: AppColors.warning),
                            const SizedBox(width: 6),
                            Text(
                              AppLocalizations.of(context).suggestedDateLabel(
                                  _fmt(request.suggestedDate!)),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.warning,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // ── Rejection Note ────────────────────────────────────
                    if (request.isRejected && request.doctorNote.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outlined,
                                size: 13, color: AppColors.error),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(request.doctorNote,
                                  style: const TextStyle(
                                      fontSize: 12, color: AppColors.error)),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // ── Actions (pending only) ─────────────────────────────
                    if (showActions && request.isPending) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _ActionBtn(
                              label: AppLocalizations.of(context).accept,
                              icon: Icons.check_circle_outline,
                              color: AppColors.success,
                              onTap: () => _ensureLocationThenAccept(context, request.id),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _ActionBtn(
                              label: AppLocalizations.of(context).suggest,
                              icon: Icons.schedule_outlined,
                              color: AppColors.warning,
                              // ✅ إصلاح الـ callback الفارغ
                              onTap: () => _showSuggestDialog(context, request.id),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _ActionBtn(
                              label: AppLocalizations.of(context).reject,
                              icon: Icons.cancel_outlined,
                              color: AppColors.error,
                              onTap: () => _showRejectDialog(context, request.id),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Location guard before accepting ──────────────────────────────────────
  /// The doctor cannot accept a request until the clinic location is set on
  /// the map. Check it first; if missing, offer to set it right away.
  Future<void> _ensureLocationThenAccept(BuildContext context, int id) async {
    final l10n = AppLocalizations.of(context);
    final dataSource = ClinicLocationDataSource(context.read<ApiClient>());

    ClinicLocation? myLocation;
    try {
      myLocation = await dataSource.fetchMyLocation();
    } catch (_) {
      myLocation = null;
    }
    if (!context.mounted) return;

    if (myLocation != null) {
      _showAcceptDialog(context, id);
      return;
    }

    // No clinic location yet → prompt the doctor to set it.
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          const Icon(Icons.location_off_outlined, color: AppColors.warning),
          const SizedBox(width: 8),
          Expanded(
            child: Text(l10n.clinicLocationRequired,
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
        ]),
        content: Text(l10n.setLocationBeforeAccept,
            style: const TextStyle(fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.location_on_outlined, size: 18),
            label: Text(l10n.setClinicLocation),
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ClinicMapPage(
                    dataSource: dataSource,
                    editable: true,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ─── Accept Dialog ────────────────────────────────────────────────────────
  void _showAcceptDialog(BuildContext context, int id) {
    final notesCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          const Icon(Icons.check_circle_outline, color: AppColors.success),
          const SizedBox(width: 8),
          Text(AppLocalizations.of(context).acceptRequest,
              style: const TextStyle(fontWeight: FontWeight.w700)),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context).appointmentCreatedAtRequestedTime,
                style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 12),
            TextField(
              controller: notesCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).optionalNoteForPatient,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.all(10),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context);
              context.read<AppointmentsCubit>().acceptRequest(
                id,
                notes: notesCtrl.text.trim(),
              );
            },
            child: Text("${AppLocalizations.of(context).confirm} ✅"),
          ),
        ],
      ),
    );
  }

  // ─── Suggest Dialog ───────────────────────────────────────────────────────
  void _showSuggestDialog(BuildContext context, int id) {
    DateTime? date;
    TimeOfDay? time;
    final noteCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(children: [
            const Icon(Icons.schedule_outlined, color: AppColors.warning),
            const SizedBox(width: 8),
            Text(AppLocalizations.of(ctx).suggestAlternativeTime,
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ]),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(ctx).patientWillBeNotifiedSuggest,
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 14),

                // Date Picker
                GestureDetector(
                  onTap: () async {
                    final p = await showDatePicker(
                      context: ctx,
                      initialDate: DateTime.now().add(const Duration(days: 1)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                    );
                    if (p != null) setStateDialog(() => date = p);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: date != null
                            ? AppColors.primary
                            : AppColors.borderLight,
                        width: date != null ? 1.5 : 0.8,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_outlined,
                            size: 16,
                            color: date != null
                                ? AppColors.primary
                                : AppColors.lightTextSecondary),
                        const SizedBox(width: 8),
                        Text(
                          date == null
                              ? AppLocalizations.of(ctx).selectDate
                              : "${date!.year}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
                          style: TextStyle(
                            fontSize: 14,
                            color: date != null ? null : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Time Picker
                GestureDetector(
                  onTap: () async {
                    final p = await showTimePicker(
                      context: ctx,
                      initialTime: const TimeOfDay(hour: 9, minute: 0),
                    );
                    if (p != null) setStateDialog(() => time = p);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: time != null
                            ? AppColors.primary
                            : AppColors.borderLight,
                        width: time != null ? 1.5 : 0.8,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.access_time_outlined,
                            size: 16,
                            color: time != null
                                ? AppColors.primary
                                : AppColors.lightTextSecondary),
                        const SizedBox(width: 8),
                        Text(
                          time == null ? AppLocalizations.of(ctx).selectTime : time!.format(ctx),
                          style: TextStyle(
                            fontSize: 14,
                            color: time != null ? null : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: noteCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(ctx).noteForPatientOptional,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.all(10),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppLocalizations.of(ctx).cancel),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                if (date == null || time == null) {
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                    content: Text(AppLocalizations.of(ctx).pleaseSelectBothDateTime),
                    backgroundColor: AppColors.error,
                  ));
                  return;
                }
                final dt = DateTime(
                  date!.year, date!.month, date!.day,
                  time!.hour, time!.minute,
                );
                Navigator.pop(ctx);
                context.read<AppointmentsCubit>().suggestAlternative(
                  id,
                  dt.toUtc().toIso8601String(),
                  noteCtrl.text.trim(),
                );
              },
              child: Text("${AppLocalizations.of(ctx).sendSuggestion} 📅"),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Reject Dialog ────────────────────────────────────────────────────────
  void _showRejectDialog(BuildContext context, int id) {
    final noteCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          const Icon(Icons.cancel_outlined, color: AppColors.error),
          const SizedBox(width: 8),
          Text(AppLocalizations.of(context).rejectRequest,
              style: const TextStyle(fontWeight: FontWeight.w700)),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppLocalizations.of(context).patientNotifiedRejection,
                style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 12),
            TextField(
              controller: noteCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).reasonForRejectionOptional,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.all(10),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context);
              context.read<AppointmentsCubit>().rejectRequest(
                id,
                doctorNote: noteCtrl.text.trim(),
              );
            },
            child: Text("${AppLocalizations.of(context).reject} ❌"),
          ),
        ],
      ),
    );
  }

  String _fmt(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      const m = ["","Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
      return "${m[dt.month]} ${dt.day}, ${dt.year}  "
          "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return raw;
    }
  }
}

// ─── Info Row ─────────────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String   label;
  final String   value;
  final bool     isDark;
  final Color?   color;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 13, color: c),
        const SizedBox(width: 6),
        Text("$label: ",
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600, color: c)),
        Expanded(
          child: Text(value,
              style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary)),
        ),
      ],
    );
  }
}

// ─── Action Button ────────────────────────────────────────────────────────────
class _ActionBtn extends StatelessWidget {
  final String       label;
  final IconData     icon;
  final Color        color;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 5),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color)),
          ],
        ),
      ),
    );
  }
}