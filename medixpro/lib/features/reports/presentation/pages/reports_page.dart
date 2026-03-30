import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medixpro/features/appointments/presentation/cubit/appointments_cubit.dart';
import 'package:medixpro/features/medications/presentation/cubit/medications_cubit.dart';
import 'package:medixpro/features/patients/presentation/cubit/patients_cubit.dart';
import 'package:medixpro/features/patients/presentation/cubit/patients_state.dart';
import 'package:medixpro/features/reports/presentation/cubit/reports_state.dart';
import '../cubit/reports_cubit.dart';
import 'report_detail_page.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final reportsCubit = context.read<ReportsCubit>();
    reportsCubit.fetchReports();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Reports"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddReportDialog(context),
          ),
        ],
      ),
      body: BlocBuilder<ReportsCubit, ReportsState>(
        builder: (context, state) {
          if (state is ReportsLoading) return const Center(child: CircularProgressIndicator());
          if (state is ReportsError) return Center(child: Text(state.message));
          if (state is ReportsLoaded) {
            if (state.reports.isEmpty) return const Center(child: Text("No reports found"));
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.reports.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, index) {
                final report = state.reports[index];
                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text(report.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Text("Status: ${report.status} | Patient: ${report.patientId}"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ReportDetailPage(report: report)),
                    ),
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showAddReportDialog(BuildContext context) {
    final titleController = TextEditingController();
    final notesController = TextEditingController();
    final diagnosisController = TextEditingController();

    final patientsCubit = context.read<PatientsCubit>();
    final medicationsCubit = context.read<MedicationsCubit>();
    final appointmentsCubit = context.read<AppointmentsCubit>();

    int? selectedPatientId;
    int? selectedAppointmentId;
    List<int> selectedMedicationIds = [];

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Report"),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(controller: titleController, decoration: const InputDecoration(labelText: "Title")),
                const SizedBox(height: 8),
                TextField(controller: notesController, decoration: const InputDecoration(labelText: "Notes")),
                const SizedBox(height: 8),
                TextField(controller: diagnosisController, decoration: const InputDecoration(labelText: "Diagnosis")),
                const SizedBox(height: 12),
                // Dropdowns للـ Patient
                DropdownButton<int>(
                  hint: const Text("Select Patient"),
                  value: selectedPatientId,
                  items: patientsCubit.state is PatientsLoaded
                      ? (patientsCubit.state as PatientsLoaded)
                          .patients
                          .map((p) => DropdownMenuItem(value: p.id, child: Text(p.name)))
                          .toList()
                      : [],
                  onChanged: (val) => selectedPatientId = val,
                ),
                // Dropdowns للـ Appointment
                DropdownButton<int>(
                  hint: const Text("Select Appointment"),
                  value: selectedAppointmentId,
                  items: appointmentsCubit.state is AppointmentsLoaded
                      ? (appointmentsCubit.state as AppointmentsLoaded)
                          .appointments
                          .map((a) => DropdownMenuItem(value: a.id, child: Text(a.title)))
                          .toList()
                      : [],
                  onChanged: (val) => selectedAppointmentId = val,
                ),
                // List of Medications (multi-select)
                if (medicationsCubit.state is MedicationsLoaded)
                  Wrap(
                    spacing: 8,
                    children: (medicationsCubit.state as MedicationsLoaded)
                        .medications
                        .map(
                          (m) => FilterChip(
                            label: Text(m.name),
                            selected: selectedMedicationIds.contains(m.id),
                            onSelected: (sel) {
                              if (sel) {
                                selectedMedicationIds.add(m.id);
                              } else {
                                selectedMedicationIds.remove(m.id);
                              }
                            },
                          ),
                        )
                        .toList(),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (selectedPatientId != null && selectedAppointmentId != null) {
                final data = {
                  "title": titleController.text,
                  "notes": notesController.text,
                  "diagnosis": diagnosisController.text,
                  "status": "draft",
                  "patient_id": selectedPatientId,
                  "medication_ids": selectedMedicationIds,
                  "appointment_id": selectedAppointmentId,
                };
                context.read<ReportsCubit>().createReport(data);
                Navigator.pop(context);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }
}