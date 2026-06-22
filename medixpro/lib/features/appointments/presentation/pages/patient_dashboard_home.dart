import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medixpro/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:medixpro/l10n/app_localizations.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/theme_cubit.dart';
import '../cubit/appointments_cubit.dart';
import '../cubit/appointments_state.dart';
import '../../../clinic_map/presentation/clinic_location_fab.dart';
import '../../../../core/widgets/app_drawer.dart';

class PatientDashboardHome extends StatefulWidget {
  const PatientDashboardHome({super.key});

  @override
  State<PatientDashboardHome> createState() => _PatientDashboardHomeState();
}

class _PatientDashboardHomeState extends State<PatientDashboardHome> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<AppointmentsCubit>().fetchAppointments(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = context.watch<AuthCubit>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      drawer: const AppDrawer(),
      floatingActionButton: const ClinicLocationFab(),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          /// 🔥 MODERN APP BAR
          SliverAppBar(
            expandedHeight: 190,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu_rounded, color: Colors.white),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
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
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// HEADER
                        Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Text(
                                  user?.username.isNotEmpty == true
                                      ? user!.username[0].toUpperCase()
                                      : "P",
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(context).welcomeBackEmoji,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  user?.username ??
                                      AppLocalizations.of(context).patient,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),

                            const Spacer(),

                            /// THEME BUTTON
                            BlocBuilder<ThemeCubit, ThemeMode>(
                              builder: (context, mode) {
                                return Container(
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
                                    ),
                                    onPressed: () => context
                                        .read<ThemeCubit>()
                                        .toggleTheme(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),

                        const Spacer(),

                        /// QUICK INFO STRIP
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.health_and_safety,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                AppLocalizations.of(context).yourHealthSimplified,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          /// 🔥 STATS (UPGRADED)
          BlocBuilder<AppointmentsCubit, AppointmentsState>(
            builder: (context, state) {
              final appointments = state is AppointmentsLoaded
                  ? state.appointments
                  : [];

              final upcoming = appointments
                  .where(
                    (a) =>
                        a.status == "scheduled" &&
                        a.dateTime.isAfter(DateTime.now()),
                  )
                  .length;

              final completed = appointments
                  .where((a) => a.status == "completed")
                  .length;

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      _ModernStatCard(
                        AppLocalizations.of(context).upcoming,
                        upcoming.toString(),
                        AppColors.primary,
                      ),
                      const SizedBox(width: 10),
                      _ModernStatCard(
                        AppLocalizations.of(context).statusCompleted,
                        completed.toString(),
                        AppColors.success,
                      ),
                      const SizedBox(width: 10),
                      _ModernStatCard(
                        AppLocalizations.of(context).total,
                        appointments.length.toString(),
                        AppColors.warning,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          /// 🔥 UPCOMING APPOINTMENTS
          BlocBuilder<AppointmentsCubit, AppointmentsState>(
            builder: (context, state) {
              if (state is AppointmentsLoading) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final upcoming = state is AppointmentsLoaded
                  ? state.appointments
                        .where(
                          (a) =>
                              a.status == "scheduled" &&
                              a.dateTime.isAfter(DateTime.now()),
                        )
                        .take(5)
                        .toList()
                  : [];

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// TITLE
                      Text(
                        AppLocalizations.of(context).upcomingAppointments,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),

                      const SizedBox(height: 14),

                      /// EMPTY STATE
                      if (upcoming.isEmpty)
                        _EmptyState(isDark: isDark)
                      else
                        ...upcoming.map((a) => _AppointmentCard(a)),
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

class _ModernStatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _ModernStatCard(this.title, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
          ),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final dynamic a;

  const _AppointmentCard(this.a);

  @override
  Widget build(BuildContext context) {
    final dt = a.dateTime.toLocal();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.05)),
        ],
      ),
      child: Row(
        children: [
          /// DATE BOX
          Container(
            width: 55,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  "${dt.day}",
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                Text("${dt.month}", style: const TextStyle(fontSize: 10)),
              ],
            ),
          ),

          const SizedBox(width: 12),

          /// DETAILS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  a.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${dt.hour}:${dt.minute.toString().padLeft(2, '0')}",
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),

          /// STATUS
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              AppLocalizations.of(context).statusScheduled,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isDark;

  const _EmptyState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).cardColor,
      ),
      child: Column(
        children: [
          const Icon(Icons.event_busy, size: 42),
          const SizedBox(height: 10),
          Text(
            AppLocalizations.of(context).noAppointmentsYet,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            AppLocalizations.of(context).startByBooking,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
