import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../domain/entities/appointment_request.dart';
import '../cubit/appointments_cubit.dart';
import '../cubit/appointments_state.dart';

class DoctorRequestsPage extends StatefulWidget {
  const DoctorRequestsPage({super.key});

  @override
  State<DoctorRequestsPage> createState() => _DoctorRequestsPageState();
}

class _DoctorRequestsPageState extends State<DoctorRequestsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<AppointmentsCubit>().fetchRequests());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<AppointmentsCubit, AppointmentsState>(
      listener: (context, state) {
        if (state is RequestActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ));
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 130,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark ? AppColors.gradientDark : AppColors.gradientLight,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                title: const Text("Appointment Requests",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                centerTitle: true,
              ),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),

            BlocBuilder<AppointmentsCubit, AppointmentsState>(
              builder: (context, state) {
                if (state is AppointmentsLoading) {
                  return const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()));
                }

                if (state is RequestsLoaded) {
                  if (state.requests.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.inbox_outlined, size: 48, color: AppColors.primary),
                            ),
                            const SizedBox(height: 14),
                            Text("No pending requests",
                                style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                )),
                          ],
                        ),
                      ),
                    );
                  }

                  // تجميع حسب الحالة
                  final pending   = state.requests.where((r) => r.isPending).toList();
                  final suggested = state.requests.where((r) => r.isSuggested).toList();
                  final others    = state.requests.where((r) => r.isAccepted || r.isRejected).toList();

                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        if (pending.isNotEmpty) ...[
                          _SectionHeader("⏳ Pending (${pending.length})", isDark),
                          ...pending.map((r) => _DoctorRequestCard(
                            request: r, isDark: isDark,
                            onAccept: () => _showAcceptDialog(context, r.id),
                            onReject: () => _showRejectDialog(context, r.id),
                            onSuggest: () => _showSuggestDialog(context, r.id),
                          )),
                          const SizedBox(height: 10),
                        ],
                        if (suggested.isNotEmpty) ...[
                          _SectionHeader("📅 Awaiting Patient Confirmation (${suggested.length})", isDark),
                          ...suggested.map((r) => _DoctorRequestCard(
                            request: r, isDark: isDark,
                          )),
                          const SizedBox(height: 10),
                        ],
                        if (others.isNotEmpty) ...[
                          _SectionHeader("✅ Resolved (${others.length})", isDark),
                          ...others.map((r) => _DoctorRequestCard(request: r, isDark: isDark)),
                        ],
                      ]),
                    ),
                  );
                }

                return const SliverFillRemaining(child: SizedBox());
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAcceptDialog(BuildContext context, int id) {
    final notesCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Accept Request", style: TextStyle(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Add optional notes for the patient:"),
            const SizedBox(height: 12),
            TextField(
              controller: notesCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: "Notes (optional)",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success, foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context);
              context.read<AppointmentsCubit>().acceptRequest(id, notes: notesCtrl.text.trim());
            },
            child: const Text("Accept ✅"),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, int id) {
    final noteCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Reject Request", style: TextStyle(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Provide a reason for rejection:"),
            const SizedBox(height: 12),
            TextField(
              controller: noteCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: "Reason (optional)",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error, foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context);
              context.read<AppointmentsCubit>().rejectRequest(id, doctorNote: noteCtrl.text.trim());
            },
            child: const Text("Reject ❌"),
          ),
        ],
      ),
    );
  }

  void _showSuggestDialog(BuildContext context, int id) {
    DateTime? date;
    TimeOfDay? time;
    final noteCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Suggest Alternative Time", style: TextStyle(fontWeight: FontWeight.w700)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Date picker
                InkWell(
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
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.borderLight),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(date == null ? "Select Date" : "${date!.year}-${date!.month.toString().padLeft(2,'0')}-${date!.day.toString().padLeft(2,'0')}"),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Time picker
                InkWell(
                  onTap: () async {
                    final p = await showTimePicker(context: ctx, initialTime: TimeOfDay.now());
                    if (p != null) setStateDialog(() => time = p);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.borderLight),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time_outlined, size: 18, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(time == null ? "Select Time" : time!.format(ctx)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: noteCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: "Note to patient (optional)",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                if (date == null || time == null) return;
                final dt = DateTime(date!.year, date!.month, date!.day, time!.hour, time!.minute);
                Navigator.pop(ctx);
                context.read<AppointmentsCubit>().suggestAlternative(
                  id, dt.toUtc().toIso8601String(), noteCtrl.text.trim(),
                );
              },
              child: const Text("Suggest 📅"),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  final bool isDark;
  const _SectionHeader(this.text, this.isDark);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(text,
          style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w700,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          )),
    );
  }
}

class _DoctorRequestCard extends StatelessWidget {
  final AppointmentRequest request;
  final bool isDark;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onSuggest;

  const _DoctorRequestCard({
    required this.request,
    required this.isDark,
    this.onAccept,
    this.onReject,
    this.onSuggest,
  });

  Color get _color {
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
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: _color, width: 4),
          top: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 0.8),
          right: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 0.8),
          bottom: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 0.8),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + Status
            Row(
              children: [
                Expanded(
                  child: Text(request.title,
                      style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      )),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(request.status.toUpperCase(),
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _color)),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Patient info
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.person_outline, size: 14, color: AppColors.primary),
                ),
                const SizedBox(width: 8),
                Text(request.patientName.isNotEmpty ? request.patientName : request.requestedByName,
                    style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    )),
              ],
            ),

            const SizedBox(height: 6),

            // Date + Type
            Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 13,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                const SizedBox(width: 5),
                Text(_formatDate(request.preferredDate),
                    style: TextStyle(fontSize: 12,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                const SizedBox(width: 12),
                Icon(Icons.category_outlined, size: 13,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                const SizedBox(width: 5),
                Text(request.type.replaceAll("_", " "),
                    style: TextStyle(fontSize: 12,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
              ],
            ),

            if (request.reason.isNotEmpty) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, size: 13, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(request.reason,
                          style: TextStyle(fontSize: 12,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                    ),
                  ],
                ),
              ),
            ],

            // Doctor actions (only for pending)
            if (request.isPending && (onAccept != null || onReject != null || onSuggest != null)) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Row(
                children: [
                  if (onAccept != null)
                    Expanded(
                      child: _ActionButton(
                        label: "Accept",
                        icon: Icons.check_circle_outline,
                        color: AppColors.success,
                        onTap: onAccept!,
                      ),
                    ),
                  if (onSuggest != null) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ActionButton(
                        label: "Suggest",
                        icon: Icons.swap_horiz_rounded,
                        color: AppColors.warning,
                        onTap: onSuggest!,
                      ),
                    ),
                  ],
                  if (onReject != null) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ActionButton(
                        label: "Reject",
                        icon: Icons.cancel_outlined,
                        color: AppColors.error,
                        onTap: onReject!,
                      ),
                    ),
                  ],
                ],
              ),
            ],

            // Suggested info
            if (request.isSuggested && request.suggestedDate != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.schedule_outlined, size: 14, color: AppColors.warning),
                    const SizedBox(width: 6),
                    Text("Suggested: ${_formatDate(request.suggestedDate!)}",
                        style: const TextStyle(fontSize: 12, color: AppColors.warning, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      return "${dt.year}-${dt.month.toString().padLeft(2,'0')}-${dt.day.toString().padLeft(2,'0')} "
          "${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}";
    } catch (_) {
      return raw;
    }
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 5),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
      ),
    );
  }
}