import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../domain/entities/appointment_request.dart';
import '../cubit/appointments_cubit.dart';
import '../cubit/appointments_state.dart';

class PatientRequestsPage extends StatefulWidget {
  const PatientRequestsPage({super.key});

  @override
  State<PatientRequestsPage> createState() => _PatientRequestsPageState();
}

class _PatientRequestsPageState extends State<PatientRequestsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    Future.microtask(() => context.read<AppointmentsCubit>().fetchRequests());
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  void _showSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content:         Text(msg, style: const TextStyle(fontSize: 13)),
      backgroundColor: color,
      behavior:        SnackBarBehavior.floating,
      margin:          const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<AppointmentsCubit, AppointmentsState>(
      listener: (context, state) {
        if (state is RequestActionSuccess) {
          _tab.animateTo(0);
          _showSnack(state.message, AppColors.success);
        } else if (state is AppointmentsError) {
          _showSnack(state.message, AppColors.error);
        }
      },
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.lightBackground,
        body: NestedScrollView(
          headerSliverBuilder: (ctx, innerBoxIsScrolled) => [
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(ctx),
              sliver: SliverAppBar(
                pinned: true,
                expandedHeight: 110,
                forceElevated: innerBoxIsScrolled,
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  titlePadding: const EdgeInsets.only(bottom: 52),
                  title: const Text("Appointments",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 17)),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? AppColors.gradientDark
                            : AppColors.gradientLight,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(46),
                  child: TabBar(
                    controller:            _tab,
                    indicatorColor:        Colors.white,
                    indicatorWeight:       3,
                    labelColor:            Colors.white,
                    unselectedLabelColor:  Colors.white54,
                    labelStyle: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13),
                    tabs: const [
                      Tab(text: "My Requests"),
                      Tab(text: "New Request"),
                    ],
                  ),
                ),
              ),
            ),
          ],
          body: TabBarView(
            controller: _tab,
            children: [
              _MyRequestsTab(isDark: isDark),
              _NewRequestTab(
                isDark:   isDark,
                onSubmit: (req) =>
                    context.read<AppointmentsCubit>().sendRequest(req),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Tab 1 ────────────────────────────────────────────────────────────────────
class _MyRequestsTab extends StatelessWidget {
  final bool isDark;
  const _MyRequestsTab({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (ctx) {
        return BlocBuilder<AppointmentsCubit, AppointmentsState>(
          builder: (context, state) {
            if (state is AppointmentsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final requests = state is RequestsLoaded
                ? state.requests
                : <AppointmentRequest>[];

            // ─── Empty ───────────────────────────────────────────────────
            if (requests.isEmpty) {
              return CustomScrollView(slivers: [
                SliverOverlapInjector(
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(ctx)),
                SliverFillRemaining(child: _EmptyState(isDark: isDark)),
              ]);
            }

            // ─── Has completed? → show clear button ───────────────────────
            final hasCompleted =
                requests.any((r) => r.isAccepted || r.isRejected);

            return CustomScrollView(
              slivers: [
                SliverOverlapInjector(
                    handle:
                        NestedScrollView.sliverOverlapAbsorberHandleFor(ctx)),

                // Clear button
                if (hasCompleted)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () => _confirmClear(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                color: AppColors.error.withOpacity(0.07),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: AppColors.error.withOpacity(0.3)),
                              ),
                              child: const Row(children: [
                                Icon(Icons.delete_sweep_outlined,
                                    size: 15, color: AppColors.error),
                                SizedBox(width: 5),
                                Text("Clear Completed",
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.error)),
                              ]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _RequestCard(
                        request:   requests[i],
                        isDark:    isDark,
                        onConfirm: requests[i].isSuggested
                            ? () => context
                                .read<AppointmentsCubit>()
                                .confirmSuggestion(requests[i].id)
                            : null,
                        onDecline: requests[i].isSuggested
                            ? () => _showDeclineDialog(
                                context, requests[i].id)
                            : null,
                      ),
                      childCount: requests.length,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmClear(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text("Clear Completed",
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text(
            "Remove all accepted and rejected requests from your list?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
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
              context.read<AppointmentsCubit>().clearCompletedRequests();
            },
            child: const Text("Clear"),
          ),
        ],
      ),
    );
  }

  void _showDeclineDialog(BuildContext context, int id) {
    final noteCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.cancel_outlined, color: AppColors.error),
          SizedBox(width: 8),
          Text("Decline Suggestion",
              style: TextStyle(fontWeight: FontWeight.w700)),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                "The doctor will be notified that you declined the suggested time.",
                style: TextStyle(fontSize: 13)),
            const SizedBox(height: 12),
            TextField(
              controller: noteCtrl,
              maxLines:   2,
              decoration: InputDecoration(
                hintText: "Reason (optional)",
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
            child: const Text("Cancel"),
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
              context.read<AppointmentsCubit>().declineSuggestion(
                id,
                patientNote: noteCtrl.text.trim(),
              );
            },
            child: const Text("Decline ❌"),
          ),
        ],
      ),
    );
  }
}

// ─── Request Card ─────────────────────────────────────────────────────────────
class _RequestCard extends StatelessWidget {
  final AppointmentRequest request;
  final bool               isDark;
  final VoidCallback?      onConfirm;
  final VoidCallback?      onDecline;

  const _RequestCard({
    required this.request,
    required this.isDark,
    this.onConfirm,
    this.onDecline,
  });

  Color get _accent {
    switch (request.status) {
      case "accepted":  return AppColors.success;
      case "rejected":  return AppColors.error;
      case "suggested": return AppColors.warning;
      default:          return AppColors.primary;
    }
  }

  String get _statusLabel {
    switch (request.status) {
      case "pending":   return "⏳  Awaiting review";
      case "accepted":  return "✅  Confirmed";
      case "rejected":  return "❌  Not approved";
      case "suggested": return "📅  New time proposed";
      default:          return request.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin:  const EdgeInsets.only(bottom: 12, left: 4),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              width: 0.8,
            ),
            boxShadow: isDark
                ? []
                : [BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title + Type badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(request.title,
                        style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        )),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      request.type.replaceAll("_", " "),
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: _accent),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Status pill
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _accent.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_statusLabel,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _accent)),
              ),

              const SizedBox(height: 10),

              _InfoRow(
                icon:   Icons.calendar_today_outlined,
                text:   "Preferred: ${_fmt(request.preferredDate)}",
                isDark: isDark,
              ),
              if (request.reason.isNotEmpty) ...[
                const SizedBox(height: 4),
                _InfoRow(
                    icon: Icons.info_outline_rounded,
                    text: request.reason,
                    isDark: isDark),
              ],
              if (request.doctorName.isNotEmpty) ...[
                const SizedBox(height: 4),
                _InfoRow(
                    icon: Icons.medical_services_outlined,
                    text: "Dr. ${request.doctorName}",
                    isDark: isDark),
              ],

              // ── Suggested alternative ─────────────────────────────────
              if (request.isSuggested && request.suggestedDate != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.warning
                        .withOpacity(isDark ? 0.1 : 0.07),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppColors.warning.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(children: [
                        Icon(Icons.swap_horiz_rounded,
                            size: 15, color: AppColors.warning),
                        SizedBox(width: 6),
                        Text("Doctor proposed a new time",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.warning,
                            )),
                      ]),
                      const SizedBox(height: 8),
                      Text(
                        _fmt(request.suggestedDate!),
                        style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                      if (request.doctorNote.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text("Note: ${request.doctorNote}",
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            )),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // ✅ زران — Confirm + Decline
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(
                            Icons.check_circle_outline_rounded, size: 16),
                        label: const Text("Confirm"),
                        onPressed: onConfirm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.cancel_outlined, size: 16),
                        label: const Text("Decline"),
                        onPressed: onDecline,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(
                              color: AppColors.error, width: 1.2),
                          padding:
                              const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              // ── Rejection note ────────────────────────────────────────
              if (request.isRejected &&
                  request.doctorNote.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outlined,
                          size: 14, color: AppColors.error),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text("Note: ${request.doctorNote}",
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.error)),
                      ),
                    ],
                  ),
                ),
              ],

              // ── Time ago ──────────────────────────────────────────────
              if (request.createdAt != null) ...[
                const SizedBox(height: 8),
                Text("Sent ${_ago(request.createdAt!)}",
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    )),
              ],
            ],
          ),
        ),

        // Accent bar
        Positioned(
          left: 0, top: 0, bottom: 12,
          child: Container(
            width: 4,
            decoration: BoxDecoration(
              color: _accent,
              borderRadius: const BorderRadius.only(
                topLeft:    Radius.circular(14),
                bottomLeft: Radius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _fmt(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      const m  = ["","Jan","Feb","Mar","Apr","May","Jun",
                   "Jul","Aug","Sep","Oct","Nov","Dec"];
      return "${m[dt.month]} ${dt.day}, ${dt.year}  "
          "${dt.hour.toString().padLeft(2, '0')}:"
          "${dt.minute.toString().padLeft(2, '0')}";
    } catch (_) { return raw; }
  }

  String _ago(String raw) {
    try {
      final d = DateTime.now()
          .difference(DateTime.parse(raw).toLocal());
      if (d.inMinutes < 1)  return "just now";
      if (d.inMinutes < 60) return "${d.inMinutes}m ago";
      if (d.inHours < 24)   return "${d.inHours}h ago";
      return "${d.inDays}d ago";
    } catch (_) { return ""; }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String   text;
  final bool     isDark;
  const _InfoRow({required this.icon, required this.text, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 13,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(text,
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              )),
        ),
      ],
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final bool isDark;
  const _EmptyState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.inbox_outlined,
                  size: 52, color: AppColors.primary),
            ),
            const SizedBox(height: 18),
            Text("No requests yet",
                style: TextStyle(
                  fontSize: 17, fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                )),
            const SizedBox(height: 8),
            Text("Tap \"New Request\" to book your first appointment",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                )),
          ],
        ),
      ),
    );
  }
}

// ─── Tab 2 ────────────────────────────────────────────────────────────────────
class _NewRequestTab extends StatefulWidget {
  final bool isDark;
  final void Function(AppointmentRequest) onSubmit;
  const _NewRequestTab({required this.isDark, required this.onSubmit});

  @override
  State<_NewRequestTab> createState() => _NewRequestTabState();
}

class _NewRequestTabState extends State<_NewRequestTab> {
  final _formKey      = GlobalKey<FormState>();
  final _titleCtrl    = TextEditingController();
  final _reasonCtrl   = TextEditingController();
  final _symptomsCtrl = TextEditingController();
  String     _type    = "general";
  DateTime?  _date;
  TimeOfDay? _time;
  bool       _loading = false;

  static const _types = [
    ("general",      Icons.health_and_safety_outlined, "General Checkup"),
    ("follow_up",    Icons.refresh_rounded,             "Follow Up"),
    ("consultation", Icons.chat_bubble_outline_rounded, "Consultation"),
    ("emergency",    Icons.emergency_outlined,           "Emergency"),
    ("lab_results",  Icons.science_outlined,             "Lab Results"),
    ("vaccination",  Icons.vaccines_outlined,            "Vaccination"),
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _reasonCtrl.dispose();
    _symptomsCtrl.dispose();
    super.dispose();
  }

  void _showErr(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content:         Text(msg),
      backgroundColor: AppColors.error,
      behavior:        SnackBarBehavior.floating,
      margin:          const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_date == null) { _showErr("Please select a date"); return; }
    if (_time == null) { _showErr("Please select a time"); return; }

    setState(() => _loading = true);

    final dt = DateTime(
      _date!.year, _date!.month, _date!.day,
      _time!.hour, _time!.minute,
    );

    widget.onSubmit(AppointmentRequest(
      id:              0,
      patientId:       0,
      patientName:     "",
      doctorName:      "",
      requestedById:   0,
      requestedByName: "",
      title:           _titleCtrl.text.trim(),
      type:            _type,
      preferredDate:   dt.toUtc().toIso8601String(),
      reason:          _reasonCtrl.text.trim(),
      symptoms:        _symptomsCtrl.text.trim(),
      status:          "pending",
      doctorNote:      "",
    ));

    _titleCtrl.clear();
    _reasonCtrl.clear();
    _symptomsCtrl.clear();
    setState(() {
      _date    = null;
      _time    = null;
      _type    = "general";
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (ctx) => CustomScrollView(
        slivers: [
          SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(ctx),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            sliver: SliverToBoxAdapter(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _Section(
                      isDark: widget.isDark,
                      title:  "Request Details",
                      icon:   Icons.edit_note_rounded,
                      child: Column(children: [
                        _field(_titleCtrl, "What do you need?",
                            "e.g. Routine checkup, back pain...",
                            Icons.title_rounded, required: true),
                        const SizedBox(height: 14),
                        _typeGrid(),
                      ]),
                    ),
                    const SizedBox(height: 14),
                    _Section(
                      isDark: widget.isDark,
                      title:  "Preferred Date & Time",
                      icon:   Icons.schedule_rounded,
                      child: Column(children: [
                        _datePicker(),
                        const SizedBox(height: 10),
                        _timePicker(),
                      ]),
                    ),
                    const SizedBox(height: 14),
                    _Section(
                      isDark: widget.isDark,
                      title:  "Additional Info (optional)",
                      icon:   Icons.description_outlined,
                      child: Column(children: [
                        _field(_reasonCtrl, "Reason for visit",
                            "Why do you need this appointment?",
                            Icons.help_outline_rounded, maxLines: 3),
                        const SizedBox(height: 12),
                        _field(_symptomsCtrl, "Symptoms",
                            "Describe your symptoms...",
                            Icons.sick_outlined, maxLines: 3),
                      ]),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity, height: 52,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 22, height: 22,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2.5, color: Colors.white))
                            : const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.send_rounded, size: 18),
                                  SizedBox(width: 8),
                                  Text("Send Request",
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700)),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController c, String label, String hint,
      IconData icon,
      {bool required = false, int maxLines = 1}) =>
      TextFormField(
        controller:  c,
        maxLines:    maxLines,
        validator:   required
            ? (v) => (v == null || v.trim().isEmpty) ? "Required" : null
            : null,
        decoration: InputDecoration(
          labelText:  label,
          hintText:   hint,
          prefixIcon: Icon(icon, size: 18, color: AppColors.primary),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
                color: widget.isDark
                    ? AppColors.borderDark
                    : AppColors.borderLight),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          filled: true,
          fillColor: widget.isDark
              ? AppColors.darkBackground
              : AppColors.lightBackground,
        ),
      );

  Widget _typeGrid() => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _types.map((t) {
          final sel = _type == t.$1;
          return GestureDetector(
            onTap: () => setState(() => _type = t.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: sel
                    ? AppColors.primary
                    : (widget.isDark
                        ? AppColors.darkBackground
                        : AppColors.lightBackground),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: sel
                      ? AppColors.primary
                      : (widget.isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(t.$2,
                      size: 14,
                      color: sel
                          ? Colors.white
                          : (widget.isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary)),
                  const SizedBox(width: 5),
                  Text(t.$3,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: sel
                            ? FontWeight.w700
                            : FontWeight.normal,
                        color: sel
                            ? Colors.white
                            : (widget.isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary),
                      )),
                ],
              ),
            ),
          );
        }).toList(),
      );

  Widget _datePicker() {
    final has = _date != null;
    return GestureDetector(
      onTap: () async {
        final p = await showDatePicker(
          context: context,
          initialDate: DateTime.now().add(const Duration(days: 1)),
          firstDate: DateTime.now(),
          lastDate: DateTime(2030),
        );
        if (p != null) setState(() => _date = p);
      },
      child: _pickerBox(
        icon:     Icons.calendar_month_rounded,
        text:     has ? _fmtDate(_date!) : "Select preferred date",
        hasValue: has,
      ),
    );
  }

  Widget _timePicker() {
    final has = _time != null;
    return GestureDetector(
      onTap: () async {
        final p = await showTimePicker(
          context: context,
          initialTime: const TimeOfDay(hour: 9, minute: 0),
        );
        if (p != null) setState(() => _time = p);
      },
      child: _pickerBox(
        icon:     Icons.access_time_rounded,
        text:     has ? _time!.format(context) : "Select preferred time",
        hasValue: has,
      ),
    );
  }

  Widget _pickerBox({
    required IconData icon,
    required String   text,
    required bool     hasValue,
  }) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: widget.isDark
              ? AppColors.darkBackground
              : AppColors.lightBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasValue
                ? AppColors.primary
                : (widget.isDark
                    ? AppColors.borderDark
                    : AppColors.borderLight),
            width: hasValue ? 1.5 : 0.8,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 18,
                color: hasValue
                    ? AppColors.primary
                    : AppColors.lightTextSecondary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(text,
                  style: TextStyle(
                    fontSize: 14,
                    color: hasValue
                        ? (widget.isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary)
                        : AppColors.lightTextSecondary,
                  )),
            ),
            Icon(Icons.chevron_right_rounded,
                size: 18,
                color: widget.isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary),
          ],
        ),
      );

  String _fmtDate(DateTime dt) {
    const m = ["","Jan","Feb","Mar","Apr","May","Jun",
                "Jul","Aug","Sep","Oct","Nov","Dec"];
    const d = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"];
    return "${d[dt.weekday - 1]}, ${m[dt.month]} ${dt.day} ${dt.year}";
  }
}

class _Section extends StatelessWidget {
  final bool     isDark;
  final String   title;
  final IconData icon;
  final Widget   child;

  const _Section({
    required this.isDark,
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 0.8,
        ),
        boxShadow: isDark
            ? []
            : [BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 15, color: AppColors.primary),
              ),
              const SizedBox(width: 8),
              Text(title,
                  style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  )),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}