import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/medication.dart';
import '../../../patients/presentation/cubit/patients_cubit.dart';
import '../../../patients/presentation/cubit/patients_state.dart';
import '../cubit/medications_cubit.dart';

class AddMedicationPage extends StatefulWidget {
  const AddMedicationPage({super.key});

  @override
  State<AddMedicationPage> createState() => _AddMedicationPageState();
}

class _AddMedicationPageState extends State<AddMedicationPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _dosageController = TextEditingController();

  int? selectedPatientId;

  @override
  void initState() {
    super.initState();
    context.read<PatientsCubit>().loadPatients();
  }

  @override
  Widget build(BuildContext context) {
    final medCubit = context.read<MedicationsCubit>();

    return Scaffold(
      appBar: AppBar(title: const Text("Add Medication")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: BlocBuilder<PatientsCubit, PatientsState>(
          builder: (context, state) {
            if (state is PatientsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is PatientsLoaded) {
              final patients = state.patients;

              return Form(
                key: _formKey,
                child: Column(
                  children: [
                    DropdownButtonFormField<int>(
                      value: selectedPatientId,
                      hint: const Text("Select Patient"),
                      items: patients.map((p) {
                        return DropdownMenuItem(
                          value: p.id,
                          child: Text(p.name),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() => selectedPatientId = val);
                      },
                      validator: (v) =>
                          v == null ? "Select patient" : null,
                    ),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: "Name"),
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),
                    TextFormField(
                      controller: _descController,
                      decoration:
                          const InputDecoration(labelText: "Description"),
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),
                    TextFormField(
                      controller: _dosageController,
                      decoration:
                          const InputDecoration(labelText: "Dosage"),
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final med = Medication(
                            id: 0,
                            patientId: selectedPatientId!,
                            patientName: "",
                            name: _nameController.text,
                            description: _descController.text,
                            dosage: _dosageController.text,
                          );

                          medCubit.addNewMedication(med);
                          Navigator.pop(context);
                        }
                      },
                      child: const Text("Add"),
                    )
                  ],
                ),
              );
            }

            return const Center(child: Text("Failed to load patients"));
          },
        ),
      ),
    );
  }
}