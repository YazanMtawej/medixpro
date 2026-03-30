import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/medication.dart';
import '../cubit/medications_cubit.dart';

import '../../../patients/presentation/cubit/patients_cubit.dart';
import '../../../patients/presentation/cubit/patients_state.dart';

class EditMedicationPage extends StatefulWidget {
  final Medication medication;

  const EditMedicationPage({
    super.key,
    required this.medication,
  });

  @override
  State<EditMedicationPage> createState() => _EditMedicationPageState();
}

class _EditMedicationPageState extends State<EditMedicationPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late final TextEditingController _dosageController;

  final _formKey = GlobalKey<FormState>();

  int? selectedPatientId;

  @override
  void initState() {
    super.initState();

    _nameController =
        TextEditingController(text: widget.medication.name);

    _descController =
        TextEditingController(text: widget.medication.description);

    _dosageController =
        TextEditingController(text: widget.medication.dosage);

    selectedPatientId = widget.medication.patientId;

    /// 🔥 تحميل المرضى
    context.read<PatientsCubit>().loadPatients();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _dosageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MedicationsCubit>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Medication"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: BlocBuilder<PatientsCubit, PatientsState>(
          builder: (context, state) {
            /// ⏳ Loading
            if (state is PatientsLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            /// ❌ Error
            if (state is PatientsError) {
              return Center(
                child: Text(state.message),
              );
            }

            /// ✅ Loaded
            if (state is PatientsLoaded) {
              final patients = state.patients;

              return Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [

                      /// 👤 Select Patient
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

                      const SizedBox(height: 16),

                      /// 📝 Name
                      TextFormField(
                        controller: _nameController,
                        decoration:
                            const InputDecoration(labelText: "Name"),
                        validator: (v) =>
                            v!.isEmpty ? "Required" : null,
                      ),

                      const SizedBox(height: 16),

                      /// 📄 Description
                      TextFormField(
                        controller: _descController,
                        decoration:
                            const InputDecoration(labelText: "Description"),
                        validator: (v) =>
                            v!.isEmpty ? "Required" : null,
                      ),

                      const SizedBox(height: 16),

                      /// 💊 Dosage
                      TextFormField(
                        controller: _dosageController,
                        decoration:
                            const InputDecoration(labelText: "Dosage"),
                        validator: (v) =>
                            v!.isEmpty ? "Required" : null,
                      ),

                      const SizedBox(height: 24),

                      /// 🚀 Update Button
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            final updatedMed = Medication(
                              id: widget.medication.id,
                              patientId: selectedPatientId!,
                              patientName: "",
                              name: _nameController.text,
                              description: _descController.text,
                              dosage: _dosageController.text,
                            );

                            cubit.updateExistingMedication(updatedMed);

                            Navigator.pop(context);
                          }
                        },
                        child: const Text("Update"),
                      ),
                    ],
                  ),
                ),
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}