import 'package:flutter/material.dart';
import 'package:medixpro/features/reports/domain/entities/report.dart';

class ReportDetailPage extends StatelessWidget {
  final Report report;

  const ReportDetailPage({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(report.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Diagnosis: ${report.diagnosis}", style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text("Notes: ${report.notes}", style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text("Status: ${report.status}", style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text("Patient ID: ${report.patientId}", style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text("Appointment ID: ${report.appointmentId}", style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text("Medications: ${report.medicationIds.join(", ")}", style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}