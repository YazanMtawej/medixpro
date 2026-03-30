class TodayAppointmentModel {

  final int id;
  final String patientName;
  final String time;
  final String status;

  TodayAppointmentModel({
    required this.id,
    required this.patientName,
    required this.time,
    required this.status,
  });

  factory TodayAppointmentModel.fromJson(Map<String, dynamic> json) {
    return TodayAppointmentModel(
      id: json["id"],
      patientName: json["patient_name"],
      time: json["time"],
      status: json["status"],
    );
  }
}