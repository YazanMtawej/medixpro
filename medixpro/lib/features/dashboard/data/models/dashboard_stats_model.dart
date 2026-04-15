class DashboardStatsModel {
  final int    totalPatients;
  final int    appointmentsToday;
  final int    totalReports;
  final int    totalMedications;
  final int    finalReports;
  final int    draftReports;
  final int    scheduledToday;
  final int    completedToday;
  final int    malePatients;
  final int    femalePatients;
  final double revenue;

  const DashboardStatsModel({
    required this.totalPatients,
    required this.appointmentsToday,
    required this.totalReports,
    required this.totalMedications,
    required this.finalReports,
    required this.draftReports,
    required this.scheduledToday,
    required this.completedToday,
    required this.malePatients,
    required this.femalePatients,
    required this.revenue,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      totalPatients:    json["total_patients"]     ?? 0,
      appointmentsToday: json["appointments_today"] ?? 0,
      totalReports:     json["total_reports"]      ?? 0,
      totalMedications: json["total_medications"]  ?? 0,
      finalReports:     json["final_reports"]      ?? 0,
      draftReports:     json["draft_reports"]      ?? 0,
      scheduledToday:   json["scheduled_today"]    ?? 0,
      completedToday:   json["completed_today"]    ?? 0,
      malePatients:     json["male_patients"]      ?? 0,
      femalePatients:   json["female_patients"]    ?? 0,
      revenue:          (json["revenue"] as num?)?.toDouble() ?? 0.0,
    );
  }
}