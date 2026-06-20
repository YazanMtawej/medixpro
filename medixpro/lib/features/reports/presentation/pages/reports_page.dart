import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medixpro/core/widgets/medical_animation.dart';
import 'package:medixpro/core/widgets/medical_loading.dart';
import 'package:medixpro/features/reports/presentation/pages/add_report_page.dart';
import 'package:medixpro/l10n/app_localizations.dart';
import '../../../../../core/theme/app_colors.dart';
import '../cubit/reports_cubit.dart';
import '../cubit/reports_state.dart';
import '../../domain/entities/report.dart';
import 'edit_report_page.dart';
import 'report_detail_page.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final _searchController = TextEditingController();
  String _selectedStatus = "all";

  Map<String, String> _statusLabels(AppLocalizations l10n) =>
      {"all": l10n.statusAll, "draft": l10n.statusDraft, "final": l10n.statusFinal};

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ReportsCubit>().fetchReports());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String v) {
    context.read<ReportsCubit>().fetchReports(
      status: _selectedStatus == "all" ? null : _selectedStatus,
      search: v.trim().isEmpty ? null : v.trim(),
    );
  }

  void _onFilterStatus(String s) {
    setState(() => _selectedStatus = s);
    context.read<ReportsCubit>().fetchReports(
      status: s == "all" ? null : s,
      search: _searchController.text.trim().isEmpty
          ? null
          : _searchController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

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
                l10n.medicalReports,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              centerTitle: true,
            ),
            backgroundColor: cs.primary,
            actions: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddReportPage()),
                  );
                  if (mounted) context.read<ReportsCubit>().fetchReports();
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
                    hintText: l10n.searchByReportTitle,
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

          // ─── Filter ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: SizedBox(
              height: 48,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                scrollDirection: Axis.horizontal,
                children: _statusLabels(l10n).entries.map((e) {
                  final selected = _selectedStatus == e.key;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => _onFilterStatus(e.key),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
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
                          e.value,
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
          BlocBuilder<ReportsCubit, ReportsState>(
            builder: (context, state) {
              if (state is ReportsLoading) {
                const SliverFillRemaining(
                  child: Center(child: MedicalLoading()),
                );
              }

              if (state is ReportsError) {
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
                          onPressed: () =>
                              context.read<ReportsCubit>().fetchReports(),
                          icon: const Icon(Icons.refresh),
                          label: Text(l10n.retry),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (state is ReportsLoaded) {
                if (state.reports.isEmpty) {
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
                              Icons.description_outlined,
                              size: 52,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.noReportsFound,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                          SizedBox(height: 12,),
                          Center(
                            child: MedicalAnimation(
                              asset: "assets/animations/Doctor and health symbols.json",
                              size: MediaQuery.of(context).size.width * 0.7,
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
                      (_, i) => _ReportCard(
                        report: state.reports[i],
                        isDark: isDark,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ReportDetailPage(report: state.reports[i]),
                          ),
                        ),
                        onEdit: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  EditReportPage(report: state.reports[i]),
                            ),
                          );
                          if (mounted) {
                            context.read<ReportsCubit>().fetchReports();
                          }
                        },
                        onDelete: () =>
                            _confirmDelete(context, state.reports[i].id),
                      ),
                      childCount: state.reports.length,
                    ),
                  ),
                );
              }

              return const SliverFillRemaining(child: SizedBox());
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: cs.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        icon: const Icon(Icons.note_add_outlined),
        label: Text(
          l10n.newReport,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddReportPage()),
          );
          if (mounted) context.read<ReportsCubit>().fetchReports();
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _confirmDelete(BuildContext context, int id) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          l10n.deleteReport,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Text(l10n.deleteReportWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
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
              context.read<ReportsCubit>().removeReport(id);
            },
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}

// ─── Report Card ──────────────────────────────────────────────────────────────
class _ReportCard extends StatelessWidget {
  final Report report;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ReportCard({
    required this.report,
    required this.isDark,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  bool get _isFinal => (report.status ?? "").toLowerCase() == "final";

  Color get _statusColor => _isFinal ? AppColors.success : AppColors.warning;

  String? get _safeDate {
    final raw = report.createdAt;
    if (raw == null || raw.isEmpty) return null;

    final dt = DateTime.tryParse(raw)?.toLocal();
    if (dt == null) return null;

    return "${dt.year.toString().padLeft(4, '0')}-"
        "${dt.month.toString().padLeft(2, '0')}-"
        "${dt.day.toString().padLeft(2, '0')}";
  }

  String _safeTitleOf(AppLocalizations l10n) =>
      report.title.isNotEmpty ? report.title : l10n.untitledReport;
  String _safePatientOf(AppLocalizations l10n) =>
      report.patientName.isNotEmpty ? report.patientName : l10n.unknownPatient;
  String get _safeDiagnosis => report.diagnosis.trim();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = _statusColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkCard.withOpacity(0.92)
            : AppColors.lightCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ───────── HEADER ─────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _IconBadge(color: color),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _safeTitleOf(l10n),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),

                          Row(
                            children: [
                              const Icon(Icons.person_outline, size: 13),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  _safePatientOf(l10n),
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
                      ),
                    ),

                    const SizedBox(width: 8),

                    _ActionColumn(onEdit: onEdit, onDelete: onDelete),
                  ],
                ),

                const SizedBox(height: 12),

                Divider(
                  height: 1,
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),

                const SizedBox(height: 12),

                // ───────── INFO ROW ─────────
                Row(
                  children: [
                    _StatusBadge(label: report.status, color: color),

                    const SizedBox(width: 8),

                    if ((report.patientBloodType ?? "").isNotEmpty &&
                        report.patientBloodType != "unknown")
                      _BloodBadge(type: report.patientBloodType!),

                    const Spacer(),

                    if (_safeDate != null)
                      _DateView(date: _safeDate!, isDark: isDark),
                  ],
                ),

                // ───────── DIAGNOSIS ─────────
                if (_safeDiagnosis.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    _safeDiagnosis,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],

                // ───────── MEDICATIONS ─────────
                if (report.medicationsDetail.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.medication_outlined,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        l10n.medicationsCount(report.medicationsDetail.length),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
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
    );
  }
}

class _IconBadge extends StatelessWidget {
  final Color color;

  const _IconBadge({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.description_outlined, color: color, size: 18),
    );
  }
}

class _ActionColumn extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ActionColumn({required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Column(
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
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String? label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final text = (label ?? "unknown").toUpperCase();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

class _BloodBadge extends StatelessWidget {
  final String type;

  const _BloodBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        type,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.red,
        ),
      ),
    );
  }
}

class _DateView extends StatelessWidget {
  final String date;
  final bool isDark;

  const _DateView({required this.date, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.calendar_today_outlined,
          size: 12,
          color: isDark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          date,
          style: TextStyle(
            fontSize: 11,
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
