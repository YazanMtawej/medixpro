class Medication {
  final int id;
  final int patientId;
  final String patientName;
  final String name;
  final String description;
  final String dosage;

  Medication({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.name,
    required this.description,
    required this.dosage,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'] ?? 0,
      patientId: json['patient'] ?? 0,
      patientName: json['patient_name'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      dosage: json['dosage'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patient': patientId,
      'name': name,
      'description': description,
      'dosage': dosage,
    };
  }
}