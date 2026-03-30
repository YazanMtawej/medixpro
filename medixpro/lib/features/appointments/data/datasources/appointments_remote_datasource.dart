import 'package:medixpro/core/network/api_client.dart';
import '../../domain/entities/appointment.dart';

class AppointmentsRemoteDataSource {
  final ApiClient api;
  AppointmentsRemoteDataSource(this.api);

  Future<List<Appointment>> getAppointments() async {
    final response = await api.dio.get("appointments/");
    final data = response.data as List;
    return data.map((e) => Appointment.fromJson(e)).toList();
  }

  Future<void> addAppointment(Map<String, dynamic> data) async {
    await api.dio.post("appointments/", data: data);
  }

  Future<void> updateAppointment(int id, Map<String, dynamic> data) async {
    await api.dio.put("appointments/$id/", data: data);
  }
}