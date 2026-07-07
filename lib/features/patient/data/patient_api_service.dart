import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';

class PatientApiService {
  final ApiClient _apiClient;

  PatientApiService(this._apiClient);

  /// GET /api/doctors
  Future<List<dynamic>> getDoctors() async {
    final response = await _apiClient.get(ApiEndpoints.doctors);
    return response.data as List<dynamic>;
  }

  /// GET /api/doctors/{id}
  Future<Map<String, dynamic>> getDoctorDetail(int id) async {
    final response = await _apiClient.get(ApiEndpoints.doctorDetail(id));
    return response.data as Map<String, dynamic>;
  }

  /// GET /api/doctors/{doctorId}/schedules
  Future<List<dynamic>> getDoctorSchedules(int doctorId) async {
    final response = await _apiClient.get(ApiEndpoints.doctorSchedules(doctorId));
    return response.data as List<dynamic>;
  }

  /// GET /api/doctors/{doctorId}/services
  Future<List<dynamic>> getDoctorServices(int doctorId) async {
    final response = await _apiClient.get(ApiEndpoints.doctorServices(doctorId));
    return response.data as List<dynamic>;
  }

  /// GET /api/doctors/{doctorId}/available-slots?date=YYYY-MM-DD
  Future<Map<String, dynamic>> getAvailableSlots(int doctorId, String date) async {
    final response = await _apiClient.get(
      ApiEndpoints.availableSlots(doctorId),
      queryParameters: {'date': date},
    );
    return response.data as Map<String, dynamic>;
  }

  /// POST /api/appointments/preview
  Future<Map<String, dynamic>> previewAppointment({
    required int doctorId,
    required int serviceId,
    required String date,
    required String time,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.appointmentPreview,
      data: {
        'doctor_id': doctorId,
        'service_id': serviceId,
        'appointment_date': date,
        'appointment_time': time,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  /// POST /api/appointments
  Future<Map<String, dynamic>> bookAppointment({
    required int doctorId,
    required int serviceId,
    required String date,
    required String time,
    String? notes,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.bookAppointment,
      data: {
        'doctor_id': doctorId,
        'service_id': serviceId,
        'appointment_date': date,
        'appointment_time': time,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  /// GET /api/appointments/my
  Future<List<dynamic>> getPatientAppointments() async {
    final response = await _apiClient.get(ApiEndpoints.patientAppointments);
    return response.data as List<dynamic>;
  }

  /// PATCH /api/appointments/{id}/cancel
  Future<Map<String, dynamic>> cancelAppointment(int id, {String? reason}) async {
    final response = await _apiClient.patch(
      ApiEndpoints.cancelAppointment(id),
      data: {
        if (reason != null && reason.isNotEmpty) 'cancellation_reason': reason,
      },
    );
    return response.data as Map<String, dynamic>;
  }
}
