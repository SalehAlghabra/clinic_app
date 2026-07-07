import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';

class DoctorApiService {
  final ApiClient _apiClient;

  DoctorApiService(this._apiClient);

  /// GET /api/appointments/doctor
  Future<List<dynamic>> getDoctorAppointments() async {
    final response = await _apiClient.get(ApiEndpoints.doctorAppointments);
    return response.data as List<dynamic>;
  }

  /// PATCH /api/appointments/{id}/status
  Future<Map<String, dynamic>> updateAppointmentStatus(int id, String status) async {
    final response = await _apiClient.patch(
      ApiEndpoints.updateAppointmentStatus(id),
      data: {'status': status},
    );
    return response.data as Map<String, dynamic>;
  }

  /// PATCH /api/appointments/cancel-day
  Future<Map<String, dynamic>> cancelDayAppointments({
    required String date,
    String? reason,
  }) async {
    final response = await _apiClient.patch(
      ApiEndpoints.cancelDayAppointments,
      data: {
        'date': date,
        if (reason != null && reason.isNotEmpty) 'cancellation_reason': reason,
      },
    );
    return response.data as Map<String, dynamic>;
  }
}
