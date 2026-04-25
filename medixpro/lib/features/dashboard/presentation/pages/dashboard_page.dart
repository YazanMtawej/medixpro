import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medixpro/core/theme/theme_cubit.dart';
import 'package:medixpro/core/widgets/medical_animation.dart';
import 'package:medixpro/core/widgets/medical_loading.dart';
import 'package:medixpro/features/appointments/presentation/pages/doctor_requests_page.dart';
import 'package:medixpro/features/appointments/presentation/pages/patient_dashboard_home.dart';
import 'package:medixpro/features/appointments/presentation/pages/patient_requests_page.dart';
import 'package:medixpro/features/auth/presentation/cubit/auth_cubit.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../patients/presentation/pages/patients_list_page.dart';
import '../../../reports/presentation/pages/reports_page.dart';
import '../../../medications/presentation/pages/medications_page.dart';
import '../../../appointments/presentation/pages/appointments_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../cubit/dashboard_cubit.dart';
import '../cubit/dashboard_state.dart';
import '../../data/models/dashboard_stats_model.dart';
import '../../data/models/today_appointment_model.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  // ─── Doctor Pages ─────────────────────────────────────────────────────────
  static const _doctorPages = <Widget>[
    _DashboardHome(),
    PatientsListPage(),
    ReportsPage(),
    MedicationsPage(),
    AppointmentsPage(),
    DoctorRequestsPage(),
    SettingsPage(),
  ];

  static const _doctorNavItems = <(IconData, IconData, String)>[
    (Icons.dashboard_rounded,      Icons.dashboard_outlined,      "Home"),
    (Icons.people_rounded,         Icons.people_outline,          "Patients"),
    (Icons.description_rounded,    Icons.description_outlined,    "Reports"),
    (Icons.medication_rounded,     Icons.medication_outlined,     "Meds"),
    (Icons.calendar_month_rounded, Icons.calendar_month_outlined, "Schedule"),
    (Icons.inbox_rounded,          Icons.inbox_outlined,          "Requests"),
    (Icons.settings_rounded,       Icons.settings_outlined,       "Settings"),
  ];

  // ─── Patient Pages ────────────────────────────────────────────────────────
  static const _patientPages = <Widget>[
    PatientDashboardHome(),
    AppointmentsPage(),
    PatientRequestsPage(),
    SettingsPage(),
  ];

  static const _patientNavItems = <(IconData, IconData, String)>[
    (Icons.home_rounded,           Icons.home_outlined,           "Home"),
    (Icons.calendar_month_rounded, Icons.calendar_month_outlined, "My Appts"),
    (Icons.send_rounded,           Icons.send_outlined,           "Requests"),
    (Icons.settings_rounded,       Icons.settings_outlined,       "Settings"),
  ];

  @override
  void initState() {
    super.initState();
    context.read<DashboardCubit>().loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final authState = context.watch<AuthCubit>().state;
    final user      = authState is AuthAuthenticated ? authState.user : null;
    final isDoctor  = user?.isDoctor ?? true; // افتراضي طبيب لو لم يُحدد

    final pages    = isDoctor ? _doctorPages    : _patientPages;
    final navItems = isDoctor ? _doctorNavItems : _patientNavItems;

    // تأكد أن الـ index لا يتجاوز عدد الصفحات
    final safeIndex = _selectedIndex.clamp(0, pages.length - 1);

    return Scaffold(
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeOut,
        child: KeyedSubtree(
          key: ValueKey(safeIndex),
          child: pages[safeIndex],
        ),
      ),
      bottomNavigationBar: _BottomNav(
        selectedIndex: safeIndex,
        isDark: isDark,
        items: navItems,
        onTap: (i) {
          // reset index عند تغيير الدور
          if (i != _selectedIndex) {
            setState(() => _selectedIndex = i);
          }
        },
      ),
    );
  }
}

// ─── Bottom Nav ───────────────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int selectedIndex;
  final bool isDark;
  final List<(IconData, IconData, String)> items;
  final void Function(int) onTap;

  const _BottomNav({
    required this.selectedIndex,
    required this.isDark,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Container(
        height: 68,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 0.8,
          ),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),

        /// 🔥 SCROLLABLE CONTENT
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: List.generate(items.length, (i) {
              final selected = selectedIndex == i;
              final item = items[i];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary.withOpacity(0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          selected ? item.$1 : item.$2,
                          size: selected ? 24 : 21,
                          color: selected
                              ? AppColors.primary
                              : (isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.$3,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.normal,
                            color: selected
                                ? AppColors.primary
                                : (isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
// ─── Dashboard Home (Doctor only) ─────────────────────────────────────────────
class _DashboardHome extends StatelessWidget {
  const _DashboardHome();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        return CustomScrollView(
          slivers: [
            // ─── AppBar ─────────────────────────────────────────────
            SliverAppBar(
              expandedHeight: 160,
              pinned: true,
              floating: false,
              flexibleSpace: FlexibleSpaceBar(
                background: _HeaderBackground(isDark: isDark),
              ),
              backgroundColor: AppColors.primary,
              elevation: 0,
              actions: [
                BlocBuilder<ThemeCubit, ThemeMode>(
                  builder: (context, mode) => Container(
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: Icon(
                        mode == ThemeMode.dark
                            ? Icons.light_mode_rounded
                            : Icons.dark_mode_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () =>
                          context.read<ThemeCubit>().toggleTheme(),
                    ),
                  ),
                ),
              ],
            ),

            if (state is DashboardLoading)
              const SliverFillRemaining(
                child: Center(child: MedicalLoading()),
              )
            else if (state is DashboardError)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off_rounded,
                          size: 52, color: AppColors.error),
                      const SizedBox(height: 12),
                      Text(state.message),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () =>
                            context.read<DashboardCubit>().loadDashboard(),
                        icon: const Icon(Icons.refresh),
                        label: const Text("Retry"),
                      ),
                    ],
                  ),
                ),
              )
            else if (state is DashboardLoaded) ...[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: _StatsGrid(stats: state.stats, isDark: isDark),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: _PatientBreakdown(stats: state.stats, isDark: isDark),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: _ReportBreakdown(stats: state.stats, isDark: isDark),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: _TodaySchedule(
                      appointments: state.appointments, isDark: isDark),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                    height: MediaQuery.of(context).padding.bottom + 100),
              ),
              
            ],
          ],
        );
      },
    );
  }
}

// ─── Header Background ────────────────────────────────────────────────────────
class _HeaderBackground extends StatelessWidget {
  final bool isDark;
  const _HeaderBackground({required this.isDark});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return "Good Morning";
    if (h < 17) return "Good Afternoon";
    return "Good Evening";
  }

  String _todayDate() {
    final now = DateTime.now();
    const months = [
      "", "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    return "${days[now.weekday - 1]}, ${months[now.month]} ${now.day}";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark ? AppColors.gradientDark : AppColors.gradientLight,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.local_hospital_rounded,
                        size: 24, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("MedixPro",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          )),
                      Text(_greeting(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          )),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(_todayDate(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        )),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Stats Grid ───────────────────────────────────────────────────────────────
class _StatsGrid extends StatelessWidget {
  final DashboardStatsModel stats;
  final bool isDark;

  const _StatsGrid({
    required this.stats,
    required this.isDark,
  });

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < 360) return 1; // 🔥 fix crash completely
    if (width < 600) return 2;
    return 2; // ممكن تخليه 3 لو تابلت لاحقًا
  }

  double _getAspectRatio(BuildContext context, int crossAxisCount) {
    final width = MediaQuery.of(context).size.width;

    if (crossAxisCount == 1) return 3.2; // card أطول شوي
    if (width < 360) return 1.8;
    if (width < 420) return 1.6;
    return 1.55;
  }

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = _getCrossAxisCount(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle("Overview", isDark),
        const SizedBox(height: 14),

        GridView.count(
          crossAxisCount: crossAxisCount,

          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),

          mainAxisSpacing: 12,
          crossAxisSpacing: 12,

          childAspectRatio:
              _getAspectRatio(context, crossAxisCount),

          children: [
            _StatCard(
              label: "Total Patients",
              value: "${stats.totalPatients}",
              icon: Icons.people_rounded,
              color: AppColors.primary,
              isDark: isDark,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PatientsListPage(),
                ),
              ),
            ),
            _StatCard(
              label: "Today's Appointments",
              value: "${stats.appointmentsToday}",
              icon: Icons.calendar_month_rounded,
              color: AppColors.success,
              isDark: isDark,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AppointmentsPage(),
                ),
              ),
            ),
            _StatCard(
              label: "Medical Reports",
              value: "${stats.totalReports}",
              icon: Icons.description_rounded,
              color: AppColors.warning,
              isDark: isDark,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ReportsPage(),
                ),
              ),
            ),
            _StatCard(
              label: "Prescriptions",
              value: "${stats.totalMedications}",
              icon: Icons.medication_rounded,
              color: Colors.purple,
              isDark: isDark,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MedicationsPage(),
                ),
              ),
            ),
          ],
        ),
         Center(
           child: MedicalAnimation(
                    asset: "assets/animations/3D Doctor Dancing.json",
                    size: MediaQuery.of(context).size.width * 0.45,
                  ),
         ),
      ],
    );
  }
}
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  double _scale(BuildContext context, double size) {
    final width = MediaQuery.of(context).size.width;

    if (width < 360) return size * 0.75;
    if (width < 420) return size * 0.9;
    return size;
  }

  @override
  Widget build(BuildContext context) {
    final valueSize = _scale(context, 18);
    final labelSize = _scale(context, 10);
    final iconSize = _scale(context, 18);
    final arrowSize = _scale(context, 12);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(_scale(context, 14)),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark
                  ? AppColors.borderDark
                  : AppColors.borderLight,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // TOP ROW
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.all(_scale(context, 8)),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      size: iconSize,
                      color: color,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: arrowSize,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // BOTTOM TEXT
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔥 VALUE (fix overflow)
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: valueSize,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 2),

                  // LABEL (safe wrap)
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: labelSize,
                      fontWeight: FontWeight.w900,
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
      ),
    );
  }
}
// ─── Patient Breakdown ────────────────────────────────────────────────────────
class _PatientBreakdown extends StatelessWidget {
  final DashboardStatsModel stats;
  final bool isDark;
  const _PatientBreakdown({required this.stats, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return _Card(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle("Patient Demographics", isDark),
          const SizedBox(height: 16),
          Row(
            children: [
              _DemoBar(
                label: "Male",
                count: stats.malePatients,
                total: stats.totalPatients,
                color: AppColors.primary,
                isDark: isDark,
              ),
              const SizedBox(width: 12),
              _DemoBar(
                label: "Female",
                count: stats.femalePatients,
                total: stats.totalPatients,
                color: Colors.pink,
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DemoBar extends StatelessWidget {
  final String label;
  final int    count;
  final int    total;
  final Color  color;
  final bool   isDark;

  const _DemoBar({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : count / total;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  )),
              Text("$count",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color,
                  )),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 8,
              backgroundColor: color.withOpacity(0.12),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 4),
          Text("${(pct * 100).toStringAsFixed(0)}%",
              style: TextStyle(
                fontSize: 11,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              )),
        ],
      ),
    );
  }
}

// ─── Report Breakdown ─────────────────────────────────────────────────────────
class _ReportBreakdown extends StatelessWidget {
  final DashboardStatsModel stats;
  final bool isDark;
  const _ReportBreakdown({required this.stats, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return _Card(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle("Today's Appointments", isDark),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  label: "Scheduled",
                  value: "${stats.scheduledToday}",
                  color: AppColors.primary,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniStat(
                  label: "Completed",
                  value: "${stats.completedToday}",
                  color: AppColors.success,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniStat(
                  label: "Final Reports",
                  value: "${stats.finalReports}",
                  color: AppColors.warning,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniStat(
                  label: "Drafts",
                  value: "${stats.draftReports}",
                  color: AppColors.lightTextSecondary,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color  color;
  final bool   isDark;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: color,
              )),
          const SizedBox(height: 4),
          Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              )),
        ],
      ),
    );
  }
}

// ─── Today Schedule ───────────────────────────────────────────────────────────
class _TodaySchedule extends StatelessWidget {
  final List<TodayAppointmentModel> appointments;
  final bool isDark;

  const _TodaySchedule({required this.appointments, required this.isDark});

  Color _statusColor(String status) {
    switch (status) {
      case "completed":   return AppColors.success;
      case "cancelled":   return AppColors.error;
      case "no_show":     return AppColors.warning;
      case "rescheduled": return Colors.orange;
      default:            return AppColors.primary;
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case "emergency":   return Icons.emergency_rounded;
      case "follow_up":   return Icons.refresh_rounded;
      case "lab_results": return Icons.science_outlined;
      case "vaccination": return Icons.vaccines_outlined;
      default:            return Icons.calendar_month_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _Card(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SectionTitle("Today's Schedule", isDark),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AppointmentsPage()),
                ),
                child: const Text("View all",
                    style: TextStyle(fontSize: 12, color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (appointments.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.event_available_outlined,
                        size: 40,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary),
                    const SizedBox(height: 8),
                    Text(
                      "No appointments today",
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...appointments.map((a) {
              final statusColor = _statusColor(a.status);
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkBackground
                            : AppColors.lightBackground,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight,
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(_typeIcon(a.type),
                                size: 16, color: AppColors.primary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(a.patientName,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: isDark
                                          ? AppColors.darkTextPrimary
                                          : AppColors.lightTextPrimary,
                                    )),
                                const SizedBox(height: 2),
                                Text(a.title,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.lightTextSecondary,
                                    )),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(a.time,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  )),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(a.status,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: statusColor,
                                    )),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Accent bar
                    Positioned(
                      left: 0, top: 0, bottom: 0,
                      child: Container(
                        width: 3,
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(14),
                            bottomLeft: Radius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────
class _Card extends StatelessWidget {
  final bool isDark;
  final Widget child;
  const _Card({required this.isDark, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  final bool   isDark;
  const _SectionTitle(this.text, this.isDark);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      ),
    );
  }
}