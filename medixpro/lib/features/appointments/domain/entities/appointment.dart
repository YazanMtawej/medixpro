class Appointment {
  final int id;
  final int patientId;
  final String patientName;
  final String patientPhone;
  final int patientAge;
  final String title;
  final String type;
  final DateTime dateTime;
  final int durationMinutes;
  final String status;
  final String reason;
  final String symptoms;
  final String diagnosis;
  final String notes;
  final String? followUpDate;
  final String? createdAt;

  const Appointment({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.patientPhone,
    required this.patientAge,
    required this.title,
    required this.type,
    required this.dateTime,
    required this.durationMinutes,
    required this.status,
    required this.reason,
    required this.symptoms,
    required this.diagnosis,
    required this.notes,
    this.followUpDate,
    this.createdAt,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id:              json["id"] ?? 0,
      patientId:       json["patient"] ?? 0,
      patientName:     json["patient_name"] ?? "",
      patientPhone:    json["patient_phone"] ?? "",
      patientAge:      json["patient_age"] ?? 0,
      title:           json["title"] ?? "",
      type:            json["type"] ?? "general",
      dateTime:        DateTime.parse(json["date_time"]),
      durationMinutes: json["duration_minutes"] ?? 30,
      status:          json["status"] ?? "scheduled",
      reason:          json["reason"] ?? "",
      symptoms:        json["symptoms"] ?? "",
      diagnosis:       json["diagnosis"] ?? "",
      notes:           json["notes"] ?? "",
      followUpDate:    json["follow_up_date"],
      createdAt:       json["created_at"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "patient":          patientId,
      "title":            title.trim(),
      "type":             type,
      "date_time":        dateTime.toUtc().toIso8601String(),
      "duration_minutes": durationMinutes,
      "status":           status,
      "reason":           reason.trim(),
      "symptoms":         symptoms.trim(),
      "diagnosis":        diagnosis.trim(),
      "notes":            notes.trim(),
      if (followUpDate != null && followUpDate!.isNotEmpty)
        "follow_up_date": followUpDate,
    };
  }

  Appointment copyWith({
    int? id,
    int? patientId,
    String? patientName,
    String? patientPhone,
    int? patientAge,
    String? title,
    String? type,
    DateTime? dateTime,
    int? durationMinutes,
    String? status,
    String? reason,
    String? symptoms,
    String? diagnosis,
    String? notes,
    String? followUpDate,
  }) {
    return Appointment(
      id:              id              ?? this.id,
      patientId:       patientId       ?? this.patientId,
      patientName:     patientName     ?? this.patientName,
      patientPhone:    patientPhone    ?? this.patientPhone,
      patientAge:      patientAge      ?? this.patientAge,
      title:           title           ?? this.title,
      type:            type            ?? this.type,
      dateTime:        dateTime        ?? this.dateTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      status:          status          ?? this.status,
      reason:          reason          ?? this.reason,
      symptoms:        symptoms        ?? this.symptoms,
      diagnosis:       diagnosis       ?? this.diagnosis,
      notes:           notes           ?? this.notes,
      followUpDate:    followUpDate    ?? this.followUpDate,
    );
  }
}