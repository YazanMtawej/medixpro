import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medixpro/core/widgets/skeleton.dart';
import 'package:medixpro/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:medixpro/l10n/app_localizations.dart';
import '../../../../../core/theme/app_colors.dart';
import '../appointment_l10n.dart';
import '../cubit/appointments_cubit.dart';
import '../cubit/appointments_state.dart';
import '../../domain/entities/appointment.dart';
import 'add_appointment_page.dart';
import 'edit_appointment_page.dart';
import 'appointment_details_page.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  final _searchController = TextEditingController();
  String _selectedStatus = "all";

  static const _statusKeys = [
    "all",
    "scheduled",
    "completed",
    "cancelled",
    "no_show",
    "rescheduled",
  ];

  String _statusFilterLabel(BuildContext context, String key) {
    if (key == "all") return AppLocalizations.of(context).statusAll;
    return appointmentStatusLabel(context, key);
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<AppointmentsCubit>().fetchAppointments(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String v) {
    context.read<AppointmentsCubit>().fetchAppointments(
      status: _selectedStatus == "all" ? null : _selectedStatus,
      search: v.trim().isEmpty ? null : v.trim(),
    );
  }

  void _onFilterStatus(String status) {
    setState(() => _selectedStatus = status);
    context.read<AppointmentsCubit>().fetchAppointments(
      status: status == "all" ? null : status,
      search: _searchController.text.trim().isEmpty
          ? null
          : _searchController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final authState = context.watch<AuthCubit>().state;
    final isDoctor = authState is AuthAuthenticated
        ? authState.user.isDoctor
        : false;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ─── AppBar ───────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 150,
            pinned: true,
            floating: false,
            flexibleSpace: FlexibleSpaceBar(
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
              title: Text(
                AppLocalizations.of(context).appointmentsTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              centerTitle: true,
            ),
            backgroundColor: cs.primary,
            actions: [
              if (isDoctor) // ← single guarded button
                IconButton(
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddAppointmentPage(),
                      ),
                    );
                    if (mounted) {
                      context.read<AppointmentsCubit>().fetchAppointments();
                    }
                  },
                ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(52),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearch,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context).searchAppointmentOrPatient,
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.65),
                      fontSize: 13,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.white.withOpacity(0.8),
                      size: 20,
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),
            ),
          ),

          // ─── Status Filter ────────────────────────────────────────
          SliverToBoxAdapter(
            child: SizedBox(
              height: 48,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                scrollDirection: Axis.horizontal,
                children: _statusKeys.map((key) {
                  final selected = _selectedStatus == key;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => _onFilterStatus(key),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? cs.primary
                              : (isDark
                                    ? AppColors.darkCard
                                    : AppColors.lightCard),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected
                                ? cs.primary
                                : (isDark
                                      ? AppColors.borderDark
                                      : AppColors.borderLight),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          _statusFilterLabel(context, key),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? Colors.white
                                : (isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // ─── List ─────────────────────────────────────────────────
          BlocBuilder<AppointmentsCubit, AppointmentsState>(
            builder: (context, state) {
              if (state is AppointmentsLoading) {
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          AppointmentCardSkeleton(isDark: isDark),
                      childCount: 6,
                    ),
                  ),
                );
              }

              if (state is AppointmentsError) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 52,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 12),
                        Text(state.message),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => context
                              .read<AppointmentsCubit>()
                              .fetchAppointments(),
                          icon: const Icon(Icons.refresh),
                          label: Text(AppLocalizations.of(context).retry),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (state is AppointmentsLoaded) {
                if (state.appointments.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.primary.withOpacity(0.1)
                                  : AppColors.chipBlue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.calendar_month_outlined,
                              size: 52,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            AppLocalizations.of(context).noAppointmentsFound,
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
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _AppointmentCard(
                        appointment: state.appointments[i],
                        isDark: isDark,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AppointmentDetailsPage(
                              appointment: state.appointments[i],
                            ),
                          ),
                        ),
                        onEdit: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditAppointmentPage(
                                appointment: state.appointments[i],
                              ),
                            ),
                          );
                          if (mounted) {
                            context
                                .read<AppointmentsCubit>()
                                .fetchAppointments();
                          }
                        },
                        onDelete: () =>
                            _confirmDelete(context, state.appointments[i].id),
                      ),
                      childCount: state.appointments.length,
                    ),
                  ),
                );
              }

              return const SliverFillRemaining(child: SizedBox());
            },
          ),
        ],
      ),

      floatingActionButton: isDoctor             // ← conditional FAB
    ? FloatingActionButton.extended(
        backgroundColor: cs.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        icon: const Icon(Icons.add),
        label: Text(
          AppLocalizations.of(context).newAppointment,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddAppointmentPage()),
          );
          if (mounted) context.read<AppointmentsCubit>().fetchAppointments();
        },
      )
    : null,                                // ← null hides FAB for patients
floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

    );
  }

  void _confirmDelete(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          AppLocalizations.of(context).deleteAppointment,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Text(AppLocalizations.of(context).appointmentDeleteWarning),
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
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              context.read<AppointmentsCubit>().deleteAppointment(id);
            },
            child: Text(AppLocalizations.of(context).delete),
          ),
        ],
      ),
    );
  }
}

// ─── Appointment Card ─────────────────────────────────────────────────────────
class _AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AppointmentCard({
    required this.appointment,
    required this.isDark,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  Color _statusColor() {
    switch (appointment.status) {
      case "completed":
        return AppColors.success;
      case "cancelled":
        return AppColors.error;
      case "no_show":
        return AppColors.warning;
      case "rescheduled":
        return Colors.orange;
      default:
        return AppColors.primary;
    }
  }

  IconData _typeIcon() {
    switch (appointment.type) {
      case "emergency":
        return Icons.emergency_rounded;
      case "follow_up":
        return Icons.refresh_rounded;
      case "lab_results":
        return Icons.science_outlined;
      case "vaccination":
        return Icons.vaccines_outlined;
      case "procedure":
        return Icons.medical_services_outlined;
      default:
        return Icons.calendar_month_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor();
    final dt = appointment.dateTime.toLocal();
    final dateStr =
        "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
    final timeStr =
        "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    final isToday = DateTime.now().difference(dt).inDays == 0;

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
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Row(
          children: [
            // 🔥 الخط الجانبي (بديل border left)
            Container(width: 4, color: statusColor),

            // المحتوى
            Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ⬇️ نفس المحتوى القديم بدون أي تغيير
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(9),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(
                                  isDark ? 0.15 : 0.08,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _typeIcon(),
                                size: 20,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          appointment.title,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: isDark
                                                ? AppColors.darkTextPrimary
                                                : AppColors.lightTextPrimary,
                                          ),
                                        ),
                                      ),
                                      if (isToday)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.warning
                                                .withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Text(
                                            AppLocalizations.of(context).today,
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.warning,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.person_outline,
                                        size: 13,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        appointment.patientName,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark
                                              ? AppColors.darkTextSecondary
                                              : AppColors.lightTextSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            Column(
                              children: [
                                _ActionBtn(
                                  icon: Icons.edit_outlined,
                                  color: AppColors.primary,
                                  onTap: onEdit,
                                ),
                                const SizedBox(height: 6),
                                _ActionBtn(
                                  icon: Icons.delete_outline,
                                  color: AppColors.error,
                                  onTap: onDelete,
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            _InfoItem(
                              Icons.calendar_today_outlined,
                              dateStr,
                              isDark,
                            ),
                            const SizedBox(width: 16),
                            _InfoItem(
                              Icons.access_time_outlined,
                              timeStr,
                              isDark,
                            ),
                            const SizedBox(width: 16),
                            _InfoItem(
                              Icons.timelapse_outlined,
                              "${appointment.durationMinutes}m",
                              isDark,
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: statusColor.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                appointmentStatusLabel(
                                    context, appointment.status),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: statusColor,
                                ),
                              ),
                            ),
                          ],
                        ),

                        if (appointment.reason.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 13,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  appointment.reason,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;

  const _InfoItem(this.icon, this.label, this.isDark);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 13,
          color: isDark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
      ],
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        borderRadius: BorderRadius.circular(9),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(7),
          child: Icon(icon, size: 17, color: color),
        ),
      ),
    );
  }
}
