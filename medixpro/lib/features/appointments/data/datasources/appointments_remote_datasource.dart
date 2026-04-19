import '../../../../core/network/api_client.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/entities/appointment_request.dart';

class AppointmentsRemoteDataSource {
  final ApiClient api;
  const AppointmentsRemoteDataSource(this.api);

  // ─── Appointments ─────────────────────────────────────────────────────────
  Future<List<Appointment>> getAppointments({
    int? patientId,
    String? status,
    String? search,
  }) async {
    final response = await api.dio.get(
      "appointments/",
      queryParameters: {
        if (patientId != null) "patient": patientId,
        if (status != null && status.isNotEmpty) "status": status,
        if (search != null && search.isNotEmpty) "search": search,
      },
    );
    final List data = response.data["data"] as List;
    return data.map((e) => Appointment.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> addAppointment(Appointment a) async {
    await api.dio.post("appointments/", data: a.toJson());
  }

  Future<void> updateAppointment(Appointment a) async {
    await api.dio.put("appointments/${a.id}/", data: a.toJson());
  }

  Future<void> deleteAppointment(int id) async {
    await api.dio.delete("appointments/$id/");
  }

  // ─── Appointment Requests ─────────────────────────────────────────────────
  Future<List<AppointmentRequest>> getRequests() async {
    final response = await api.dio.get("appointment-requests/");
    final List data = response.data["data"] as List;
    return data.map((e) => AppointmentRequest.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> sendRequest(AppointmentRequest req) async {
    await api.dio.post("appointment-requests/", data: req.toJson());
  }

  Future<void> acceptRequest(int id, {String notes = ""}) async {
    await api.dio.post(
      "appointment-requests/$id/accept/",
      data: {"notes": notes},
    );
  }

  Future<void> rejectRequest(int id, {String doctorNote = ""}) async {
    await api.dio.post(
      "appointment-requests/$id/reject/",
      data: {"doctor_note": doctorNote},
    );
  }

  Future<void> suggestAlternative(int id, String suggestedDate, String note) async {
    await api.dio.post(
      "appointment-requests/$id/suggest/",
      data: {"suggested_date": suggestedDate, "doctor_note": note},
    );
  }

  Future<void> confirmSuggestion(int id) async {
    await api.dio.post("appointment-requests/$id/confirm/");
  }
}