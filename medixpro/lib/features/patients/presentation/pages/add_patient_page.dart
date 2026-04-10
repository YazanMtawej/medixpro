import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/patient.dart';
import '../cubit/patients_cubit.dart';

class AddPatientPage extends StatefulWidget {
  const AddPatientPage({super.key});

  @override
  State<AddPatientPage> createState() => _AddPatientPageState();
}

class _AddPatientPageState extends State<AddPatientPage> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final phoneController = TextEditingController();
  final notesController = TextEditingController();

  String gender = "Male";
  DateTime? birthDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Patient"),
        centerTitle: true,
      ),

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surface.withOpacity(0.9),
            ],
          ),
        ),

        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Form(
            key: _formKey,

            child: ListView(
              children: [

                Text(
                  "Patient Information",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                _field(nameController, "Full Name", Icons.person),
                const SizedBox(height: 12),

                _field(
                  ageController,
                  "Age",
                  Icons.cake,
                  type: TextInputType.number,
                ),

                const SizedBox(height: 12),

                _field(phoneController, "Phone", Icons.phone),
                const SizedBox(height: 12),

                /// Gender modern chips
                _genderSelector(),

                const SizedBox(height: 12),

                /// Birth date modern selector
                _dateSelector(context),

                const SizedBox(height: 12),

                _field(notesController, "Notes (optional)", Icons.notes),

                const SizedBox(height: 30),

                ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text("Save Patient"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController c,
    String label,
    IconData icon, {
    TextInputType type = TextInputType.text,
  }) {
    return TextFormField(
      controller: c,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
    );
  }

  Widget _genderSelector() {
    return Row(
      children: [
        ChoiceChip(
          label: const Text("Male"),
          selected: gender == "Male",
          onSelected: (_) => setState(() => gender = "Male"),
        ),
        const SizedBox(width: 10),
        ChoiceChip(
          label: const Text("Female"),
          selected: gender == "Female",
          onSelected: (_) => setState(() => gender = "Female"),
        ),
      ],
    );
  }

 Widget _dateSelector(BuildContext context) {
  final theme = Theme.of(context);

  return ListTile(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    ),

    tileColor: theme.colorScheme.surfaceContainerHighest,

    leading: Icon(
      Icons.calendar_month,
      color: theme.colorScheme.primary,
    ),

    title: Text(
      birthDate == null
          ? "Select Birth Date"
          : birthDate!.toIso8601String().split("T").first,
      style: TextStyle(color: theme.colorScheme.onSurface),
    ),

    onTap: _pickDate,
  );
}
  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final patient = Patient(
      id: 0,
      name: nameController.text,
      age: int.parse(ageController.text),
      phone: phoneController.text,
      gender: gender,
      birthDate:
          birthDate?.toIso8601String().split("T").first,
      notes: notesController.text,
    );

    context.read<PatientsCubit>().addPatient(patient);
    Navigator.pop(context);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => birthDate = picked);
    }
  }
}