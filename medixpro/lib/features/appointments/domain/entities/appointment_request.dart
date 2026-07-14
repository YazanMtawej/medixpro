class AppointmentRequest {
  final int     id;
  final int     patientId;
  final String  patientName;
  final int?    doctorId;
  final String  doctorName;
  final String  doctorClinicName;
  final String  doctorAddress;
  final double? doctorLatitude;
  final double? doctorLongitude;
  final int     requestedById;
  final String  requestedByName;
  final String  title;
  final String  type;
  final String  preferredDate;
  final String  reason;
  final String  symptoms;
  final String  status;
  final String? suggestedDate;
  final String  doctorNote;
  final int?    appointmentId;
  final String? createdAt;

  const AppointmentRequest({
    required this.id,
    required this.patientId,
    required this.patientName,
    this.doctorId,
    required this.doctorName,
    this.doctorClinicName = "",
    this.doctorAddress = "",
    this.doctorLatitude,
    this.doctorLongitude,
    required this.requestedById,
    required this.requestedByName,
    required this.title,
    required this.type,
    required this.preferredDate,
    required this.reason,
    required this.symptoms,
    required this.status,
    this.suggestedDate,
    required this.doctorNote,
    this.appointmentId,
    this.createdAt,
  });

  factory AppointmentRequest.fromJson(Map<String, dynamic> json) {
    return AppointmentRequest(
      id:              json["id"]                ?? 0,
      patientId:       json["patient"]           ?? 0,
      patientName:     json["patient_name"]      ?? "",
      doctorId:        json["doctor"],
      doctorName:      json["doctor_name"]       ?? "",
      doctorClinicName: json["doctor_clinic_name"] ?? "",
      doctorAddress:    json["doctor_address"]     ?? "",
      doctorLatitude:  (json["doctor_latitude"]  as num?)?.toDouble(),
      doctorLongitude: (json["doctor_longitude"] as num?)?.toDouble(),
      requestedById:   json["requested_by"]      ?? 0,
      requestedByName: json["requested_by_name"] ?? "",
      title:           json["title"]             ?? "",
      type:            json["type"]              ?? "general",
      preferredDate:   json["preferred_date"]    ?? "",
      reason:          json["reason"]            ?? "",
      symptoms:        json["symptoms"]          ?? "",
      status:          json["status"]            ?? "pending",
      suggestedDate:   json["suggested_date"],
      doctorNote:      json["doctor_note"]       ?? "",
      appointmentId:   json["appointment"],
      createdAt:       json["created_at"],
    );
  }

  // ✅ يرسل فقط ما يحتاجه الـ server
  Map<String, dynamic> toJson() => {
    "title":          title,
    "type":           type,
    "preferred_date": preferredDate,
    "reason":         reason,
    "symptoms":       symptoms,
  };

  bool get hasDoctorLocation =>
      doctorLatitude != null && doctorLongitude != null;

  bool get isPending   => status == "pending";
  bool get isAccepted  => status == "accepted";
  bool get isRejected  => status == "rejected";
  bool get isSuggested => status == "suggested";
}