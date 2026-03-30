class Appointment {
  final int id;
  final String title;
  final int? patientId; // 🔥 اجعلها int? بدلاً من int
  final String patientName;
  final DateTime dateTime;
  final String status;

  Appointment({
    required this.id,
    required this.title,
    this.patientId, // 🔥 اختياري
    required this.patientName,
    required this.dateTime,
    required this.status,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      title: json['title'] ?? "Untitled",
      patientId: json['patient'], // قد يكون null
      patientName: json['patient_name'] ?? '',
      dateTime: DateTime.parse(json['date_time']),
      status: json['status'] ?? "Scheduled",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'patient': patientId,
      'date_time': dateTime.toUtc().toIso8601String(),
      'status': status,
    };
  }
}