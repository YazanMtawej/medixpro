import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medixpro/l10n/app_localizations.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../domain/entities/appointment.dart';
import '../appointment_l10n.dart';
import '../cubit/appointments_cubit.dart';
import 'edit_appointment_page.dart';

class AppointmentDetailsPage extends StatelessWidget {
  final Appointment appointment;
  const AppointmentDetailsPage({super.key, required this.appointment});

  Color _statusColor() {
    switch (appointment.status) {
      case "completed":   return AppColors.success;
      case "cancelled":   return AppColors.error;
      case "no_show":     return AppColors.warning;
      case "rescheduled": return Colors.orange;
      default:            return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n        = AppLocalizations.of(context);
    final isDark      = Theme.of(context).brightness == Brightness.dark;
    final statusColor = _statusColor();
    final dt          = appointment.dateTime.toLocal();

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
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
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 48, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: statusColor.withOpacity(0.4)),
                          ),
                          child: Text(
                            appointmentStatusLabel(context, appointment.status)
                                .toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: statusColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          appointment.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.white),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditAppointmentPage(
                          appointment: appointment),
                    ),
                  );
                  if (context.mounted) {
                    context.read<AppointmentsCubit>().fetchAppointments();
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ─── Patient Card ────────────────────────────────────
                _InfoCard(
                  isDark: isDark,
                  title: l10n.patientLabel,
                  icon: Icons.person_outline,
                  children: [
                    _Row(l10n.name,  appointment.patientName, isDark),
                    _Row(l10n.phone, appointment.patientPhone.isNotEmpty
                        ? appointment.patientPhone
                        : "—", isDark),
                    _Row(l10n.age,   appointment.patientAge > 0
                        ? l10n.ageYears(appointment.patientAge.toString())
                        : "—", isDark),
                  ],
                ),

                const SizedBox(height: 14),

                // ─── Appointment Details ─────────────────────────────
                _InfoCard(
                  isDark: isDark,
                  title: l10n.appointmentDetails,
                  icon: Icons.calendar_month_outlined,
                  children: [
                    _Row(l10n.dateLabel, "${dt.year}-${dt.month.toString().padLeft(2,'0')}-${dt.day.toString().padLeft(2,'0')}",
                        isDark),
                    _Row(l10n.timeLabel, "${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}",
                        isDark),
                    _Row(l10n.duration, l10n.minutesValue(appointment.durationMinutes), isDark),
                    _Row(l10n.typeLabel,   appointmentTypeLabel(context, appointment.type), isDark),
                    _Row(l10n.status, appointmentStatusLabel(context, appointment.status), isDark),
                    if (appointment.followUpDate != null &&
                        appointment.followUpDate!.isNotEmpty)
                      _Row(l10n.followUp, appointment.followUpDate!, isDark),
                  ],
                ),

                const SizedBox(height: 14),

                // ─── Clinical Info ───────────────────────────────────
                if (appointment.reason.isNotEmpty ||
                    appointment.symptoms.isNotEmpty ||
                    appointment.diagnosis.isNotEmpty ||
                    appointment.notes.isNotEmpty)
                  _InfoCard(
                    isDark: isDark,
                    title: l10n.clinicalInformation,
                    icon: Icons.medical_information_outlined,
                    children: [
                      if (appointment.reason.isNotEmpty)
                        _TextBlock(
                            l10n.reasonForVisit, appointment.reason, isDark),
                      if (appointment.symptoms.isNotEmpty)
                        _TextBlock(l10n.symptoms, appointment.symptoms, isDark),
                      if (appointment.diagnosis.isNotEmpty)
                        _TextBlock(
                            l10n.diagnosis, appointment.diagnosis, isDark),
                      if (appointment.notes.isNotEmpty)
                        _TextBlock(
                            l10n.doctorNotes, appointment.notes, isDark),
                    ],
                  ),

                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final bool isDark;
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _InfoCard({
    required this.isDark,
    required this.title,
    required this.icon,
    required this.children,
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
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  )),
            ],
          ),
          const Divider(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;

  const _Row(this.label, this.value, this.isDark);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                )),
          ),
          Expanded(
            child: Text(value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                )),
          ),
        ],
      ),
    );
  }
}

class _TextBlock extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;

  const _TextBlock(this.label, this.value, this.isDark);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              )),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.primary.withOpacity(0.05)
                  : AppColors.chipBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(value,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                )),
          ),
        ],
      ),
    );
  }
}