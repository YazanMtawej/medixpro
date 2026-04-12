import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/patient.dart';
import '../cubit/patients_cubit.dart';
import 'edit_patient_page.dart';

class PatientDetailsPage extends StatelessWidget {
  final Patient patient;
  const PatientDetailsPage({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(patient.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditPatientPage(patient: patient),
                ),
              );
              if (context.mounted) {
                context.read<PatientsCubit>().loadPatients();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ─── Header Card ─────────────────────────────────────────────────
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor:
                          patient.gender.toLowerCase() == "female"
                              ? Colors.pink.shade100
                              : Colors.blue.shade100,
                      child: Text(
                        patient.name.isNotEmpty
                            ? patient.name[0].toUpperCase()
                            : "?",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: patient.gender.toLowerCase() == "female"
                              ? Colors.pink
                              : Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(patient.name,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(
                            "${patient.age} years · ${patient.gender}",
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border:
                                  Border.all(color: Colors.red.shade200),
                            ),
                            child: Text(
                              "Blood: ${patient.bloodType}",
                              style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            _InfoSection(title: "Contact Information", items: [
              _InfoItem(Icons.phone, "Phone", patient.phone),
              if (patient.email?.isNotEmpty == true)
                _InfoItem(Icons.email, "Email", patient.email!),
              if (patient.address?.isNotEmpty == true)
                _InfoItem(Icons.location_on, "Address", patient.address!),
              if (patient.nationalId?.isNotEmpty == true)
                _InfoItem(Icons.badge, "National ID", patient.nationalId!),
              if (patient.birthDate?.isNotEmpty == true)
                _InfoItem(Icons.cake, "Birth Date", patient.birthDate!),
            ]),

            if (patient.emergencyContactName?.isNotEmpty == true ||
                patient.emergencyContactPhone?.isNotEmpty == true)
              _InfoSection(title: "Emergency Contact", items: [
                if (patient.emergencyContactName?.isNotEmpty == true)
                  _InfoItem(Icons.contact_phone, "Name",
                      patient.emergencyContactName!),
                if (patient.emergencyContactPhone?.isNotEmpty == true)
                  _InfoItem(Icons.phone_forwarded, "Phone",
                      patient.emergencyContactPhone!),
              ]),

            _InfoSection(title: "Medical Information", items: [
              if (patient.allergies?.isNotEmpty == true)
                _InfoItem(Icons.warning_amber, "Allergies", patient.allergies!),
              if (patient.chronicDiseases?.isNotEmpty == true)
                _InfoItem(Icons.medical_information, "Chronic Diseases",
                    patient.chronicDiseases!),
              if (patient.previousSurgeries?.isNotEmpty == true)
                _InfoItem(Icons.history, "Previous Surgeries",
                    patient.previousSurgeries!),
              if (patient.currentMedications?.isNotEmpty == true)
                _InfoItem(Icons.medication, "Current Medications",
                    patient.currentMedications!),
              if (patient.notes?.isNotEmpty == true)
                _InfoItem(Icons.note, "Notes", patient.notes!),
            ]),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final List<Widget> items;

  const _InfoSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  )),
              const Divider(height: 16),
              ...items,
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade500),
          const SizedBox(width: 10),
          SizedBox(
            width: 110,
            child: Text(label,
                style: TextStyle(
                    color: Colors.grey.shade600, fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.w500, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}