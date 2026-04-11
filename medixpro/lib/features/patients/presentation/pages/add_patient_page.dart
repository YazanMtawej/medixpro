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

    return Scaffold(
      appBar: AppBar(title: const Text("Add Patient")),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Form(
          key: _formKey,

          child: ListView(
            children: [

              /// Name
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name"),
                validator: (v) =>
                    v == null || v.isEmpty ? "Enter name" : null,
              ),

              const SizedBox(height: 16),

              /// Age
              TextFormField(
                controller: ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Age"),
                validator: (v) {
                  if (v == null || v.isEmpty) return "Enter age";
                  if (int.tryParse(v) == null) return "Invalid number";
                  return null;
                },
              ),

              const SizedBox(height: 16),

              /// Phone
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: "Phone"),
                validator: (v) =>
                    v == null || v.isEmpty ? "Enter phone" : null,
              ),

              const SizedBox(height: 16),

              /// Gender
              DropdownButtonFormField<String>(
                value: gender,
                decoration: const InputDecoration(labelText: "Gender"),
                items: ["Male", "Female"]
                    .map((g) =>
                        DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (val) {
                  setState(() => gender = val!);
                },
              ),

              const SizedBox(height: 16),

              /// Birth Date
              ListTile(
                title: Text(
                  birthDate == null
                      ? "Select Birth Date"
                      : "${birthDate!.toLocal()}".split(' ')[0],
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),

              const SizedBox(height: 16),

              /// Notes
              TextFormField(
                controller: notesController,
                decoration: const InputDecoration(labelText: "Notes"),
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: _submit,
                child: const Text("Save"),
              ),
            ],
          ),
        ),
      ),
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
      birthDate: birthDate != null
          ? "${birthDate!.toLocal()}".split(' ')[0]
          : null,
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