import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medixpro/features/auth/presentation/cubit/auth_cubit.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/theme_cubit.dart';
import '../cubit/appointments_cubit.dart';
import '../cubit/appointments_state.dart';

class PatientDashboardHome extends StatefulWidget {
  const PatientDashboardHome({super.key});

  @override
  State<PatientDashboardHome> createState() => _PatientDashboardHomeState();
}

class _PatientDashboardHomeState extends State<PatientDashboardHome> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<AppointmentsCubit>().fetchAppointments());
  }

  @override
  Widget build(BuildContext context) {
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final authState = context.watch<AuthCubit>().state;
    final user      = authState is AuthAuthenticated ? authState.user : null;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: CustomScrollView(
        slivers: [
          // ─── AppBar ───────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 170,
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
                              width: 50, height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Center(
                                child: Text(
                                  user?.username.isNotEmpty == true
                                      ? user!.username[0].toUpperCase()
                                      : "P",
                                  style: const TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Welcome back,",
                                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                                Text(user?.username ?? "Patient",
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                              ],
                            ),
                            const Spacer(),
                            BlocBuilder<ThemeCubit, ThemeMode>(
                              builder: (context, mode) => Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    mode == ThemeMode.dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                                    color: Colors.white, size: 20,
                                  ),
                                  onPressed: () => context.read<ThemeCubit>().toggleTheme(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text("Patient Portal 🏥",
                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            backgroundColor: AppColors.primary,
          ),

          // ─── Stats ────────────────────────────────────────────────────────
          BlocBuilder<AppointmentsCubit, AppointmentsState>(
            builder: (context, state) {
              final appointments = state is AppointmentsLoaded ? state.appointments : [];
              final upcoming     = appointments.where((a) => a.status == "scheduled" && a.dateTime.isAfter(DateTime.now())).length;
              final completed    = appointments.where((a) => a.status == "completed").length;

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      _StatChip(label: "Upcoming", value: "$upcoming", color: AppColors.primary, isDark: isDark),
                      const SizedBox(width: 12),
                      _StatChip(label: "Completed", value: "$completed", color: AppColors.success, isDark: isDark),
                      const SizedBox(width: 12),
                      _StatChip(label: "Total", value: "${appointments.length}", color: AppColors.warning, isDark: isDark),
                    ],
                  ),
                ),
              );
            },
          ),

          // ─── Upcoming Appointments ────────────────────────────────────────
          BlocBuilder<AppointmentsCubit, AppointmentsState>(
            builder: (context, state) {
              if (state is AppointmentsLoading) {
                return const SliverToBoxAdapter(
                    child: Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator())));
              }

              final upcoming = state is AppointmentsLoaded
                  ? state.appointments.where((a) => a.status == "scheduled" && a.dateTime.isAfter(DateTime.now())).take(5).toList()
                  : [];

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Upcoming Appointments",
                          style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          )),
                      const SizedBox(height: 12),
                      if (upcoming.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkCard : AppColors.lightCard,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isDark ? AppColors.borderDark : AppColors.borderLight,
                              width: 0.8,
                            ),
                          ),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.event_available_outlined, size: 40,
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                                const SizedBox(height: 8),
                                Text("No upcoming appointments",
                                    style: TextStyle(
                                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                    )),
                                const SizedBox(height: 4),
                                Text("Go to Requests tab to book one",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                    )),
                              ],
                            ),
                          ),
                        )
                      else
                        ...upcoming.map((a) {
                          final dt  = a.dateTime.toLocal();
                          final str = "${dt.year}-${dt.month.toString().padLeft(2,'0')}-${dt.day.toString().padLeft(2,'0')} "
                              "${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}";
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkCard : AppColors.lightCard,
                              borderRadius: BorderRadius.circular(14),
                              border: Border(
                                left: const BorderSide(color: AppColors.primary, width: 3),
                                top: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 0.8),
                                right: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 0.8),
                                bottom: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 0.8),
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
                                  child: const Icon(Icons.calendar_month_outlined, size: 18, color: AppColors.primary),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(a.title,
                                          style: TextStyle(
                                            fontSize: 13, fontWeight: FontWeight.w700,
                                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                          )),
                                      const SizedBox(height: 2),
                                      Text(str,
                                          style: TextStyle(fontSize: 12,
                                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text("Scheduled",
                                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.success)),
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color  color;
  final bool   isDark;

  const _StatChip({required this.label, required this.value, required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 0.8),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 11,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
          ],
        ),
      ),
    );
  }
}