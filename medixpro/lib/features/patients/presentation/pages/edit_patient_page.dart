import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/patient.dart';
import '../cubit/patients_cubit.dart';

class EditPatientPage extends StatefulWidget {

  final Patient patient;

  const EditPatientPage({super.key, required this.patient});

  @override
  State<EditPatientPage> createState() => _EditPatientPageState();
}

class _EditPatientPageState extends State<EditPatientPage> {

  late TextEditingController nameController;
  late TextEditingController ageController;
  late TextEditingController phoneController;
  late String gender;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.patient.name);
    ageController = TextEditingController(text: widget.patient.age.toString());
    phoneController = TextEditingController(text: widget.patient.phone);
    gender = widget.patient.gender;
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Patient"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Age"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: "Phone"),
            ),
            const SizedBox(height: 16),
            DropdownButton<String>(
              value: gender,
              items: const [
                DropdownMenuItem(value: "Male", child: Text("Male")),
                DropdownMenuItem(value: "Female", child: Text("Female")),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    gender = val;
                  });
                }
              },
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                final updatedPatient = Patient(
                  id: widget.patient.id,
                  name: nameController.text,
                  age: int.parse(ageController.text),
                  phone: phoneController.text,
                  gender: gender,
                );

                context.read<PatientsCubit>().updatePatient(
                      widget.patient.id,
                      updatedPatient,
                    );

                Navigator.pop(context);
              },
              child: const Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }
}