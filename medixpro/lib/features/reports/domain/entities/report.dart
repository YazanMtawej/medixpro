class ReportMedication {
  final int id;
  final String name;
  final String dosage;
  final String frequency;
  final String route;

  const ReportMedication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.route,
  });

  factory ReportMedication.fromJson(Map<String, dynamic> json) {
    return ReportMedication(
      id:        json["id"] ?? 0,
      name:      json["name"] ?? "",
      dosage:    json["dosage"] ?? "",
      frequency: json["frequency"] ?? "",
      route:     json["route"] ?? "",
    );
  }
}

class ReportAppointment {
  final int id;
  final String title;
  final String type;
  final String dateTime;
  final String status;

  const ReportAppointment({
    required this.id,
    required this.title,
    required this.type,
    required this.dateTime,
    required this.status,
  });

  factory ReportAppointment.fromJson(Map<String, dynamic> json) {
    return ReportAppointment(
      id:       json["id"] ?? 0,
      title:    json["title"] ?? "",
      type:     json["type"] ?? "",
      dateTime: json["date_time"] ?? "",
      status:   json["status"] ?? "",
    );
  }
}

class Report {
  final int id;
  final int patientId;
  final String patientName;
  final String patientAge;
  final String patientPhone;
  final String patientBloodType;
  final String patientAllergies;
  final int? appointmentId;
  final ReportAppointment? appointmentDetail;
  final List<int> medicationIds;
  final List<ReportMedication> medicationsDetail;
  final String title;
  final String status;
  final String chiefComplaint;
  final String history;
  final String examination;
  final String diagnosis;
  final String treatmentPlan;
  final String notes;
  final String? followUpDate;
  final String? createdAt;
  final String? updatedAt;

  const Report({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.patientAge,
    required this.patientPhone,
    required this.patientBloodType,
    required this.patientAllergies,
    this.appointmentId,
    this.appointmentDetail,
    required this.medicationIds,
    required this.medicationsDetail,
    required this.title,
    required this.status,
    required this.chiefComplaint,
    required this.history,
    required this.examination,
    required this.diagnosis,
    required this.treatmentPlan,
    required this.notes,
    this.followUpDate,
    this.createdAt,
    this.updatedAt,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    final medsRaw = json["medications_detail"] as List? ?? [];
    final apptRaw = json["appointment_detail"];

    return Report(
      id:                json["id"] ?? 0,
      patientId:         json["patient"] ?? 0,
      patientName:       json["patient_name"] ?? "",
      patientAge:        json["patient_age"]?.toString() ?? "",
      patientPhone:      json["patient_phone"] ?? "",
      patientBloodType:  json["patient_blood_type"] ?? "",
      patientAllergies:  json["patient_allergies"] ?? "",
      appointmentId:     json["appointment"],
      appointmentDetail: apptRaw != null
          ? ReportAppointment.fromJson(apptRaw as Map<String, dynamic>)
          : null,
      medicationIds: (json["medication_ids"] as List? ?? [])
          .map((e) => e as int)
          .toList(),
      medicationsDetail: medsRaw
          .map((e) =>
              ReportMedication.fromJson(e as Map<String, dynamic>))
          .toList(),
      title:          json["title"] ?? "",
      status:         json["status"] ?? "draft",
      chiefComplaint: json["chief_complaint"] ?? "",
      history:        json["history"] ?? "",
      examination:    json["examination"] ?? "",
      diagnosis:      json["diagnosis"] ?? "",
      treatmentPlan:  json["treatment_plan"] ?? "",
      notes:          json["notes"] ?? "",
      followUpDate:   json["follow_up_date"],
      createdAt:      json["created_at"],
      updatedAt:      json["updated_at"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "patient":         patientId,
      if (appointmentId != null) "appointment": appointmentId,
      "medication_ids":  medicationIds,
      "title":           title.trim(),
      "status":          status,
      "chief_complaint": chiefComplaint.trim(),
      "history":         history.trim(),
      "examination":     examination.trim(),
      "diagnosis":       diagnosis.trim(),
      "treatment_plan":  treatmentPlan.trim(),
      "notes":           notes.trim(),
      if (followUpDate != null && followUpDate!.isNotEmpty)
        "follow_up_date": followUpDate,
    };
  }

  Report copyWith({
    int? id,
    int? patientId,
    int? appointmentId,
    List<int>? medicationIds,
    String? title,
    String? status,
    String? chiefComplaint,
    String? history,
    String? examination,
    String? diagnosis,
    String? treatmentPlan,
    String? notes,
    String? followUpDate,
  }) {
    return Report(
      id:               id               ?? this.id,
      patientId:        patientId        ?? this.patientId,
      patientName:      patientName,
      patientAge:       patientAge,
      patientPhone:     patientPhone,
      patientBloodType: patientBloodType,
      patientAllergies: patientAllergies,
      appointmentId:    appointmentId    ?? this.appointmentId,
      appointmentDetail: appointmentDetail,
      medicationIds:    medicationIds    ?? this.medicationIds,
      medicationsDetail: medicationsDetail,
      title:            title            ?? this.title,
      status:           status           ?? this.status,
      chiefComplaint:   chiefComplaint   ?? this.chiefComplaint,
      history:          history          ?? this.history,
      examination:      examination      ?? this.examination,
      diagnosis:        diagnosis        ?? this.diagnosis,
      treatmentPlan:    treatmentPlan    ?? this.treatmentPlan,
      notes:            notes            ?? this.notes,
      followUpDate:     followUpDate     ?? this.followUpDate,
      createdAt:        createdAt,
      updatedAt:        updatedAt,
    );
  }
}