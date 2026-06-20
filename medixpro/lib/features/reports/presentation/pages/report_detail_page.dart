import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medixpro/l10n/app_localizations.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../domain/entities/report.dart';
import '../cubit/reports_cubit.dart';
import 'edit_report_page.dart';

class ReportDetailPage extends StatelessWidget {
  final Report report;
  const ReportDetailPage({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isFinal = report.status == "final";

    String? dateStr;
    if (report.createdAt != null) {
      final dt = DateTime.tryParse(report.createdAt!)?.toLocal();
      if (dt != null) {
        dateStr =
            "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
      }
    }

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
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
                    padding: const EdgeInsets.fromLTRB(20, 50, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: (isFinal
                                        ? AppColors.success
                                        : AppColors.warning)
                                    .withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: (isFinal
                                          ? AppColors.success
                                          : AppColors.warning)
                                      .withOpacity(0.5),
                                ),
                              ),
                              child: Text(
                                report.status.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: isFinal
                                      ? AppColors.success
                                      : AppColors.warning,
                                ),
                              ),
                            ),
                            if (dateStr != null) ...[
                              const SizedBox(width: 8),
                              Text(
                                dateStr,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          report.title,
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
                      builder: (_) => EditReportPage(report: report),
                    ),
                  );
                  if (context.mounted) {
                    context.read<ReportsCubit>().fetchReports();
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
                // ─── Patient Info ───────────────────────────────────
                _Section(
                  isDark: isDark,
                  title: l10n.patientInformation,
                  icon: Icons.person_outline,
                  children: [
                    _Row(l10n.name,       report.patientName,       isDark),
                    _Row(l10n.age,        report.patientAge.isNotEmpty ? l10n.ageYears(report.patientAge) : "—", isDark),
                    _Row(l10n.phone,      report.patientPhone.isNotEmpty ? report.patientPhone : "—", isDark),
                    _Row(l10n.bloodType, report.patientBloodType.isNotEmpty ? report.patientBloodType : "—", isDark),
                    if (report.patientAllergies.isNotEmpty)
                      _HighlightRow(l10n.allergies, report.patientAllergies,
                          AppColors.error, isDark),
                  ],
                ),

                const SizedBox(height: 14),

                // ─── Appointment ────────────────────────────────────
                if (report.appointmentDetail != null)
                  _Section(
                    isDark: isDark,
                    title: l10n.linkedAppointment,
                    icon: Icons.calendar_month_outlined,
                    children: [
                      _Row(l10n.titleLabel,  report.appointmentDetail!.title,  isDark),
                      _Row(l10n.typeLabel,   report.appointmentDetail!.type.replaceAll("_", " "), isDark),
                      _Row(l10n.status, report.appointmentDetail!.status, isDark),
                    ],
                  ),

                if (report.appointmentDetail != null) const SizedBox(height: 14),

                // ─── Clinical ───────────────────────────────────────
                _Section(
                  isDark: isDark,
                  title: l10n.clinicalInformation,
                  icon: Icons.medical_information_outlined,
                  children: [
                    if (report.chiefComplaint.isNotEmpty)
                      _TextBlock(l10n.chiefComplaint,
                          report.chiefComplaint, isDark),
                    if (report.history.isNotEmpty)
                      _TextBlock(l10n.medicalHistory, report.history, isDark),
                    if (report.examination.isNotEmpty)
                      _TextBlock(l10n.physicalExamination,
                          report.examination, isDark),
                    _TextBlock(l10n.diagnosis, report.diagnosis, isDark,
                        highlight: true),
                    if (report.treatmentPlan.isNotEmpty)
                      _TextBlock(l10n.treatmentPlan,
                          report.treatmentPlan, isDark),
                    if (report.notes.isNotEmpty)
                      _TextBlock(l10n.doctorNotes, report.notes, isDark),
                    if (report.followUpDate != null &&
                        report.followUpDate!.isNotEmpty)
                      _Row(l10n.followUpDate, report.followUpDate!, isDark),
                  ],
                ),

                // ─── Medications ────────────────────────────────────
                if (report.medicationsDetail.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _Section(
                    isDark: isDark,
                    title: l10n.prescribedMedications,
                    icon: Icons.medication_outlined,
                    children: report.medicationsDetail
                        .map((m) => _MedCard(med: m, isDark: isDark))
                        .toList(),
                  ),
                ],

                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final bool isDark;
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _Section({
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
            width: 110,
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

class _HighlightRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _HighlightRow(this.label, this.value, this.color, this.isDark);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                )),
          ),
          Expanded(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(value,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  )),
            ),
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
  final bool highlight;

  const _TextBlock(this.label, this.value, this.isDark,
      {this.highlight = false});

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
              color: highlight
                  ? AppColors.primary.withOpacity(isDark ? 0.12 : 0.07)
                  : (isDark
                      ? AppColors.primary.withOpacity(0.05)
                      : AppColors.chipBlue),
              borderRadius: BorderRadius.circular(8),
              border: highlight
                  ? Border.all(
                      color: AppColors.primary.withOpacity(0.3))
                  : null,
            ),
            child: Text(value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      highlight ? FontWeight.w600 : FontWeight.normal,
                  color: highlight
                      ? (isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.primary)
                      : (isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary),
                )),
          ),
        ],
      ),
    );
  }
}

class _MedCard extends StatelessWidget {
  final ReportMedication med;
  final bool isDark;

  const _MedCard({required this.med, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(isDark ? 0.08 : 0.05),
        borderRadius: BorderRadius.circular(10),
        border:
            Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.medication_rounded,
              size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(med.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    )),
                const SizedBox(height: 2),
                Text(
                  "${med.dosage} · ${med.frequency.replaceAll("_", " ")} · ${med.route}",
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}