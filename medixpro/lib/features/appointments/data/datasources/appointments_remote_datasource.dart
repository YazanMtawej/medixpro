import '../../../../core/network/api_client.dart';
import '../../domain/entities/appointment.dart';

class AppointmentsRemoteDataSource {
  final ApiClient api;
  const AppointmentsRemoteDataSource(this.api);

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
    return data
        .map((e) => Appointment.fromJson(e as Map<String, dynamic>))
        .toList();
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
}