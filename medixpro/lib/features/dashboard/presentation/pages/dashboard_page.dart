import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medixpro/core/theme/theme_cubit.dart';
import 'package:medixpro/features/appointments/presentation/pages/appointments_page.dart';
import 'package:medixpro/features/medications/presentation/pages/medications_page.dart';
import 'package:medixpro/features/patients/presentation/pages/patients_list_page.dart';
import 'package:medixpro/features/reports/presentation/pages/reports_page.dart';
import 'package:medixpro/features/settings/presentation/pages/settings_page.dart';

import '../cubit/dashboard_cubit.dart';
import '../cubit/dashboard_state.dart';
import '../widgets/stats_card.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = [
    DashboardContent(),
    PatientsListPage(),
    ReportsPage(),
    MedicationsPage(),
    AppointmentsPage(),
    SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    context.read<DashboardCubit>().loadDashboard();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBody: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withOpacity(0.95),
                theme.colorScheme.primaryContainer.withOpacity(0.7),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.local_hospital, color: Colors.white),
                  const SizedBox(width: 10),
                  const Text(
                    "MedixPro Dashboard",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),

                  // Theme toggle (Modern pill button)
                  BlocBuilder<ThemeCubit, ThemeMode>(
                    builder: (context, themeMode) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: IconButton(
                          icon: Icon(
                            themeMode == ThemeMode.dark
                                ? Icons.light_mode_rounded
                                : Icons.dark_mode_rounded,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            context.read<ThemeCubit>().toggleTheme();
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_selectedIndex],
      ),

      // 🔥 Modern Floating Bottom Navigation
      bottomNavigationBar: _ModernBottomNav(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is DashboardLoaded) {
          final stats = state.stats;

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).colorScheme.surface,
                  Theme.of(context).colorScheme.surface.withOpacity(0.95),
                ],
              ),
            ),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SizedBox(height: 10),

                // Header section
                Text(
                  "Overview",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),

                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    StatsCard(
                      title: "Patients",
                      value: stats.patients.toString(),
                      icon: Icons.people,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PatientsListPage(),
                          ),
                        );
                      },
                    ),
                    StatsCard(
                      title: "Appointments Today",
                      value: stats.appointmentsToday.toString(),
                      icon: Icons.calendar_today,
                      onTap: () { Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AppointmentsPage(),
                          ),
                        );},
                    ),
                    StatsCard(
                      title: "Reports",
                      value: stats.reports.toString(),
                      icon: Icons.description,
                      onTap: () { Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ReportsPage(),
                          ),
                        );},
                    ),
                    StatsCard(
                      title: "Revenue",
                      value: stats.revenue.toString(),
                      icon: Icons.attach_money,
                      onTap: () {},
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Quick action section (modern touch)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withOpacity(0.4),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.insights),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Your clinic is performing well today 🚀",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        if (state is DashboardError) {
          return Center(
            child: Text(state.message),
          );
        }

        return const SizedBox();
      },
    );
  }
}

/// 🔥 Modern Bottom Navigation (Floating + Animated)
class _ModernBottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const _ModernBottomNav({
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withOpacity(0.9),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.dashboard, 0, "Home"),
            _navItem(Icons.people, 1, "Patients"),
            _navItem(Icons.description, 2, "Reports"),
            _navItem(Icons.medical_services, 3, "Meds"),
            _navItem(Icons.calendar_today, 4, "Dates"),
            _navItem(Icons.settings, 5, "Settings"),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, int index, String label) {
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue : Colors.grey,
              size: isSelected ? 26 : 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? Colors.blue : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}