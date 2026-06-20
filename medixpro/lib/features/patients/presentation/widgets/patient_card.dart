import 'package:flutter/material.dart';
import 'package:medixpro/l10n/app_localizations.dart';
import '../../domain/entities/patient.dart';

class PatientCard extends StatelessWidget {

  final Patient patient;

  const PatientCard(this.patient, {super.key});

  @override
  Widget build(BuildContext context) {

    return Card(

      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),

      child: ListTile(

        leading: const CircleAvatar(
          child: Icon(Icons.person),
        ),

        title: Text(patient.name),

        subtitle: Text(
          AppLocalizations.of(context).agePhoneLabel(patient.age, patient.phone),
        ),
      ),
    );
  }
}