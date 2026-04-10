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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Patient"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            _field(nameController, "Name", Icons.person),
            const SizedBox(height: 12),

            _field(ageController, "Age", Icons.cake, type: TextInputType.number),
            const SizedBox(height: 12),

            _field(phoneController, "Phone", Icons.phone),

            const SizedBox(height: 12),

            Row(
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
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text("Save Changes"),
                onPressed: () {
                  final updated = Patient(
                    id: widget.patient.id,
                    name: nameController.text,
                    age: int.parse(ageController.text),
                    phone: phoneController.text,
                    gender: gender,
                  );

                  context.read<PatientsCubit>().updatePatient(
                        widget.patient.id,
                        updated,
                      );

                  Navigator.pop(context);
                },
              ),
            )
          ],
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
  final theme = Theme.of(context);

  return TextField(
    controller: c,
    keyboardType: type,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: theme.colorScheme.primary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ),
  );
}
}