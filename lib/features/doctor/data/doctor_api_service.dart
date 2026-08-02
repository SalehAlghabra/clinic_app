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
  Future<Map<String, dynamic>> updateAppointmentStatus(
    int id,
    String status, {
    double? additionalCost,
    String? additionalNote,
  }) async {
    final data = <String, dynamic>{'status': status};
    if (status == 'completed') {
      if (additionalCost != null) data['additional_cost'] = additionalCost;
      if (additionalNote != null && additionalNote.isNotEmpty) {
        data['additional_note'] = additionalNote;
      }
    }

    final response = await _apiClient.patch(
      ApiEndpoints.updateAppointmentStatus(id),
      data: data,
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
