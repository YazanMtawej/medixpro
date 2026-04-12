class Medication {
  final int id;
  final int patientId;
  final String patientName;
  final String name;
  final String dosage;
  final String frequency;
  final String route;
  final int? durationDays;
  final String? startDate;
  final String? endDate;
  final String instructions;
  final String notes;
  final String? createdAt;

  const Medication({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.route,
    this.durationDays,
    this.startDate,
    this.endDate,
    this.instructions = "",
    this.notes = "",
    this.createdAt,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json["id"] ?? 0,
      patientId: json["patient"] ?? 0,
      patientName: json["patient_name"] ?? "",
      name: json["name"] ?? "",
      dosage: json["dosage"] ?? "",
      frequency: json["frequency"] ?? "once_daily",
      route: json["route"] ?? "oral",
      durationDays: json["duration_days"],
      startDate: json["start_date"],
      endDate: json["end_date"],
      instructions: json["instructions"] ?? "",
      notes: json["notes"] ?? "",
      createdAt: json["created_at"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "patient": patientId,
      "name": name.trim(),
      "dosage": dosage.trim(),
      "frequency": frequency,
      "route": route,
      if (durationDays != null) "duration_days": durationDays,
      if (startDate != null && startDate!.isNotEmpty) "start_date": startDate,
      if (endDate != null && endDate!.isNotEmpty) "end_date": endDate,
      "instructions": instructions.trim(),
      "notes": notes.trim(),
    };
  }

  Medication copyWith({
    int? id,
    int? patientId,
    String? patientName,
    String? name,
    String? dosage,
    String? frequency,
    String? route,
    int? durationDays,
    String? startDate,
    String? endDate,
    String? instructions,
    String? notes,
  }) {
    return Medication(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      route: route ?? this.route,
      durationDays: durationDays ?? this.durationDays,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      instructions: instructions ?? this.instructions,
      notes: notes ?? this.notes,
    );
  }
}

class CommonMedication {
  final int id;
  final String name;
  final String category;

  const CommonMedication({
    required this.id,
    required this.name,
    required this.category,
  });

  factory CommonMedication.fromJson(Map<String, dynamic> json) {
    return CommonMedication(
      id: json["id"] ?? 0,
      name: json["name"] ?? "",
      category: json["category"] ?? "",
    );
  }
}