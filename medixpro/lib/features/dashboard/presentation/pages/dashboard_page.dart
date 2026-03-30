import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medixpro/core/theme/theme_cubit.dart';
import 'package:medixpro/features/appointments/presentation/pages/appointments_page.dart';
import 'package:medixpro/features/medications/presentation/pages/medications_page.dart';
import 'package:medixpro/features/patients/presentation/pages/patients_list_page.dart';
import 'package:medixpro/features/reports/presentation/pages/reports_page.dart';

import 'package:medixpro/features/settings/presentation/pages/settings_page.dart';
// استورد أي صفحات ثانية تريدها هنا
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: [
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, theme) {
              return IconButton(
                icon: Icon(
                  theme == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
                ),
                onPressed: () {
                  context.read<ThemeCubit>().toggleTheme();
                },
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _pages[_selectedIndex], // نعرض الصفحة حسب الاختيار
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Patients'),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: 'Reports',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services),
            label: 'Medications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
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
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              StatsCard(
                title: "Patients",
                value: stats.patients.toString(),
                icon: Icons.people,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PatientsListPage()),
                  );
                },
              ),
              const SizedBox(height: 12),
              StatsCard(
                title: "Appointments Today",
                value: stats.appointmentsToday.toString(),
                icon: Icons.calendar_today,
                onTap: () {},
              ),
              const SizedBox(height: 12),
              StatsCard(
                title: "Reports",
                value: stats.reports.toString(),
                icon: Icons.description,
                onTap: () {},
              ),
              const SizedBox(height: 12),
              StatsCard(
                title: "Revenue",
                value: stats.revenue.toString(),
                icon: Icons.attach_money,
                onTap: () {},
              ),
            ],
          );
        }
        if (state is DashboardError) {
          return Center(child: Text(state.message));
        }
        return const SizedBox();
      },
    );
  }
}
