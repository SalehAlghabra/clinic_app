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
}
