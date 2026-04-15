class TodayAppointmentModel {
  final int    id;
  final String title;
  final String patientName;
  final int    patientAge;
  final String time;
  final String type;
  final String status;
  final int    duration;

  const TodayAppointmentModel({
    required this.id,
    required this.title,
    required this.patientName,
    required this.patientAge,
    required this.time,
    required this.type,
    required this.status,
    required this.duration,
  });

  factory TodayAppointmentModel.fromJson(Map<String, dynamic> json) {
    return TodayAppointmentModel(
      id:          json["id"]           ?? 0,
      title:       json["title"]        ?? "",
      patientName: json["patient_name"] ?? "",
      patientAge:  json["patient_age"]  ?? 0,
      time:        json["time"]         ?? "",
      type:        json["type"]         ?? "general",
      status:      json["status"]       ?? "scheduled",
      duration:    json["duration"]     ?? 30,
    );
  }
}