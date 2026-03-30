class Report {
  final int id;
  final String title;
  final String diagnosis;
  final String notes;
  final String status;
  final int patientId;
  final List<int> medicationIds;
  final int appointmentId;
  final DateTime createdAt;

  Report({
    required this.id,
    required this.title,
    required this.diagnosis,
    required this.notes,
    required this.status,
    required this.patientId,
    required this.medicationIds,
    required this.appointmentId,
    required this.createdAt,
  });

  factory Report.fromJson(Map<String, dynamic> json) => Report(
        id: json['id'],
        title: json['title'],
        diagnosis: json['diagnosis'],
        notes: json['notes'] ?? '',
        status: json['status'],
        patientId: json['patient_id'],
        medicationIds: List<int>.from(json['medication_ids']),
        appointmentId: json['appointment_id'],
        createdAt: DateTime.parse(json['created_at']),
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "diagnosis": diagnosis,
        "notes": notes,
        "status": status,
        "patient_id": patientId,
        "medication_ids": medicationIds,
        "appointment_id": appointmentId,
      };
}