class DashboardStatsModel {

  final int patients;
  final int appointmentsToday;
  final int reports;
  final double revenue;

  DashboardStatsModel({
    required this.patients,
    required this.appointmentsToday,
    required this.reports,
    required this.revenue,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      patients: json["patients"],
      appointmentsToday: json["appointments_today"],
      reports: json["reports"],
      revenue: (json["revenue"] as num).toDouble(),
    );
  }
}