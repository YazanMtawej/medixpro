import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/patients_cubit.dart';
import '../cubit/patients_state.dart';
import '../../domain/entities/patient.dart';
import 'edit_patient_page.dart';

class PatientDetailsPage extends StatelessWidget {
  final int patientId;

  const PatientDetailsPage({
    super.key,
    required this.patientId,
  });

  @override
  Widget build(BuildContext context) {
    Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Patient Profile"),
      ),

      body: BlocBuilder<PatientsCubit, PatientsState>(
        builder: (context, state) {
          if (state is PatientsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PatientsLoaded) {
            final patient = state.patients.firstWhere(
              (p) => p.id == patientId,
              orElse: () => throw Exception("Patient not found"),
            );

            return _buildContent(context, patient);
          }

          return const SizedBox();
        },
      ),
    );
  }

  /// ================= CONTENT =================
  Widget _buildContent(BuildContext context, Patient patient) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),

      child: Column(
        children: [

          /// ================= AVATAR =================
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  cs.primary,
                  cs.primaryContainer,
                ],
              ),
            ),
            child: Center(
              child: Text(
                patient.name.isNotEmpty ? patient.name[0] : "?",
                style: const TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          /// ================= NAME =================
          Text(
            patient.name,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),

          const SizedBox(height: 20),

          /// ================= INFO CARDS =================
          _tile(context, Icons.cake, "Age", "${patient.age}"),
          _tile(context, Icons.phone, "Phone", patient.phone),
          _tile(context, Icons.person, "Gender", patient.gender),

          const SizedBox(height: 30),

          /// ================= EDIT BUTTON =================
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.edit),
              label: const Text("Edit Patient"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),

              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditPatientPage(patient: patient),
                  ),
                );

                /// 🔥 refresh after edit
                context.read<PatientsCubit>().loadPatients();
              },
            ),
          ),
        ],
      ),
    );
  }

  /// ================= TILE (FIXED) =================
  Widget _tile(
    BuildContext context,
    IconData icon,
    String title,
    String value,
  ) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),

      child: ListTile(
        leading: Icon(
          icon,
          color: cs.primary,
        ),

        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
          ),
        ),

        subtitle: Text(
          value,
          style: TextStyle(
            color: cs.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}