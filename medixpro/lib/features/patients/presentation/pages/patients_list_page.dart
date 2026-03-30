import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/patients_cubit.dart';
import '../cubit/patients_state.dart';
import '../../domain/entities/patient.dart';

import 'add_patient_page.dart';
import 'edit_patient_page.dart';
import 'patient_details_page.dart';

class PatientsListPage extends StatefulWidget {
  const PatientsListPage({super.key});

  @override
  State<PatientsListPage> createState() => _PatientsListPageState();
}

class _PatientsListPageState extends State<PatientsListPage> {

  @override
  void initState() {
    super.initState();
    context.read<PatientsCubit>().loadPatients();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Patients"),
      ),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {

          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddPatientPage(),
            ),
          );

          context.read<PatientsCubit>().loadPatients();
        },
      ),

      body: BlocBuilder<PatientsCubit, PatientsState>(
        builder: (context, state) {

          if (state is PatientsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PatientsError) {
            return Center(child: Text(state.message));
          }

          if (state is PatientsLoaded) {

            if (state.patients.isEmpty) {
              return const Center(child: Text("No patients found"));
            }

            return RefreshIndicator(
              onRefresh: () async {
                await context.read<PatientsCubit>().loadPatients();
              },
              child: ListView.builder(
                itemCount: state.patients.length,
                itemBuilder: (_, index) {

                  final patient = state.patients[index];

                  return _buildPatientCard(context, patient);
                },
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildPatientCard(BuildContext context, Patient patient) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.person),
        ),

        title: Text(patient.name),

        subtitle: Text(
          "Age: ${patient.age} | ${patient.phone}",
        ),

        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PatientDetailsPage(patient: patient),
            ),
          );
        },

        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [

            /// ✏️ Edit
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {

                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditPatientPage(patient: patient),
                  ),
                );

                context.read<PatientsCubit>().loadPatients();
              },
            ),

            /// 🗑 Delete
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                _showDeleteDialog(context, patient.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Patient"),
        content: const Text("Are you sure?"),
        actions: [

          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),

          ElevatedButton(
            onPressed: () async {

              Navigator.pop(context);

              /// 🔥 لازم تضيف delete في cubit (رح أعطيك تحت)
              await context.read<PatientsCubit>().deletePatient(id);

            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}