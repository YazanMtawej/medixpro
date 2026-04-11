import 'package:flutter/material.dart';
import '../../domain/entities/patient.dart';
import 'edit_patient_page.dart';

class PatientDetailsPage extends StatelessWidget {

  final Patient patient;

  const PatientDetailsPage({
    super.key,
    required this.patient,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text("Patient Details"),

        actions: [

          IconButton(

            icon: const Icon(Icons.edit),

            onPressed: () {

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      EditPatientPage(patient: patient),
                ),
              );
            },
          )
        ],
      ),

      body: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Text(
              patient.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Text("Age: ${patient.age}"),

            const SizedBox(height: 10),

            Text("Phone: ${patient.phone}"),

            const SizedBox(height: 10),

            Text("Gender: ${patient.gender}"),
          ],
        ),
      ),
    );
  }
}