import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medixpro/features/appointments/presentation/cubit/appointments_cubit.dart';
import 'package:medixpro/features/appointments/presentation/pages/add_appointment_page.dart';
import 'package:medixpro/features/appointments/presentation/pages/edit_appointment_page.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  @override
  void initState() {
    super.initState();
    context.read<AppointmentsCubit>().fetchAppointments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Appointments")),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddAppointmentPage()),
          );

          context.read<AppointmentsCubit>().fetchAppointments();
        },
        child: const Icon(Icons.add),
      ),

      body: BlocBuilder<AppointmentsCubit, AppointmentsState>(
        builder: (context, state) {
          if (state is AppointmentsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AppointmentsLoaded) {
            return ListView.builder(
              padding: const EdgeInsets.all(12),

              itemCount: state.appointments.length,

              itemBuilder: (_, index) {
                final appt = state.appointments[index];

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),

                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),

                    title: Text(appt.title),

                    subtitle: Text(
                      "${appt.patientName.isNotEmpty ? appt.patientName : "Unknown Patient"}\n${appt.dateTime}",
                    ),

                    trailing: Chip(label: Text(appt.status)),

                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              EditAppointmentPage(appointment: appt),
                        ),
                      );

                      context.read<AppointmentsCubit>().fetchAppointments();
                    },
                  ),
                );
              },
            );
          }

          if (state is AppointmentsError) {
            return Center(child: Text(state.message));
          }

          return const SizedBox();
        },
      ),
    );
  }
}
