import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:medixpro/core/theme/app_colors.dart';
import 'package:medixpro/l10n/app_localizations.dart';
import '../../data/models/dashboard_stats_model.dart';

///════════════════════════════════════════════════════════════
/// PREMIUM ANALYTICS CARDS
///════════════════════════════════════════════════════════════

class AppointmentStatusChart extends StatelessWidget {
  final DashboardStatsModel stats;
  final bool isDark;

  const AppointmentStatusChart({
    super.key,
    required this.stats,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final scheduled = stats.scheduledToday;
    final completed = stats.completedToday;
    final total = scheduled + completed;

    if (total == 0) return const SizedBox();

    final completionRate = ((completed / total) * 100).round();

    final l10n = AppLocalizations.of(context);
    return _AnalyticsCard(
      isDark: isDark,
      title: l10n.appointmentsPerformance,
      subtitle: l10n.liveOverviewToday,
      trailing: _StatusChip(
        text: l10n.successRate(completionRate),
        color: AppColors.success,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 4,
                child: SizedBox(
                  height: 170,
                  child: PieChart(
                    PieChartData(
                      centerSpaceRadius: 42,
                      sectionsSpace: 4,
                      startDegreeOffset: -90,
                      sections: [
                        PieChartSectionData(
                          value: scheduled.toDouble(),
                          color: AppColors.primary,
                          radius: 56,
                          title: "$scheduled",
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                        PieChartSectionData(
                          value: completed.toDouble(),
                          color: AppColors.success,
                          radius: 56,
                          title: "$completed",
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    _MetricTile(
                      isDark: isDark,
                      color: AppColors.primary,
                      title: l10n.statusScheduled,
                      value: "$scheduled",
                      subtitle: l10n.pendingVisits,
                    ),
                    const SizedBox(height: 10),
                    _MetricTile(
                      isDark: isDark,
                      color: AppColors.success,
                      title: l10n.statusCompleted,
                      value: "$completed",
                      subtitle: l10n.finishedToday,
                    ),
                    const SizedBox(height: 10),
                    _MetricTile(
                      isDark: isDark,
                      color: AppColors.warning,
                      title: l10n.total,
                      value: "$total",
                      subtitle: l10n.allAppointments,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _InsightBanner(
            isDark: isDark,
            icon: Icons.insights_rounded,
            text: completionRate >= 70
                ? l10n.clinicStrongToday
                : l10n.roomToImprove,
          ),
        ],
      ),
    );
  }
}

///════════════════════════════════════════════════════════════
/// PATIENT ANALYTICS
///════════════════════════════════════════════════════════════

class PatientGenderChart extends StatelessWidget {
  final DashboardStatsModel stats;
  final bool isDark;

  const PatientGenderChart({
    super.key,
    required this.stats,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final male = stats.malePatients;
    final female = stats.femalePatients;
    final total = stats.totalPatients;

    if (total == 0) return const SizedBox();

    final maleRate = ((male / total) * 100).round();
    final femaleRate = ((female / total) * 100).round();

    final l10n = AppLocalizations.of(context);
    return _AnalyticsCard(
      isDark: isDark,
      title: l10n.patientDemographics,
      subtitle: l10n.populationDistribution,
      trailing: _StatusChip(
        text: l10n.patientsCount(total),
        color: AppColors.primary,
      ),
      child: Column(
        children: [
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                maxY: total * 1.25,
                alignment: BarChartAlignment.spaceAround,
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  drawVerticalLine: false,
                  horizontalInterval: total / 4,
                  getDrawingHorizontalLine: (_) => FlLine(
                    strokeWidth: .6,
                    color: isDark
                        ? Colors.white10
                        : Colors.black12,
                  ),
                ),
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final labels = [l10n.male, l10n.female, l10n.total];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            labels[value.toInt()],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: [
                  _bar(0, male.toDouble(), AppColors.primary),
                  _bar(1, female.toDouble(), Colors.pink),
                  _bar(2, total.toDouble(), AppColors.warning),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SmallInfoCard(
                  isDark: isDark,
                  title: l10n.maleRatio,
                  value: "$maleRate%",
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SmallInfoCard(
                  isDark: isDark,
                  title: l10n.femaleRatio,
                  value: "$femaleRate%",
                  color: Colors.pink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _InsightBanner(
            isDark: isDark,
            icon: Icons.groups_rounded,
            text: female > male
                ? l10n.femaleLargerSegment
                : l10n.maleLargerSegment,
          ),
        ],
      ),
    );
  }

  BarChartGroupData _bar(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          width: 30,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(8),
          ),
          color: color,
        ),
      ],
    );
  }
}

///════════════════════════════════════════════════════════════
/// SHARED WIDGETS
///════════════════════════════════════════════════════════════

class _AnalyticsCard extends StatelessWidget {
  final bool isDark;
  final String title;
  final String subtitle;
  final Widget trailing;
  final Widget child;

  const _AnalyticsCard({
    required this.isDark,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(.04),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
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
              trailing,
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final bool isDark;
  final Color color;
  final String title;
  final String value;
  final String subtitle;

  const _MetricTile({
    required this.isDark,
    required this.color,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withOpacity(.14),
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
                Text(
                  subtitle,
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
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallInfoCard extends StatelessWidget {
  final bool isDark;
  final String title;
  final String value;
  final Color color;

  const _SmallInfoCard({
    required this.isDark,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String text;
  final Color color;

  const _StatusChip({
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(.10),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _InsightBanner extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final String text;

  const _InsightBanner({
    required this.isDark,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}