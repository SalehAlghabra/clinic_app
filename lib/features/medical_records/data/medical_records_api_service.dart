import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';

class MedicalRecordsApiService {
  final ApiClient _apiClient;

  MedicalRecordsApiService(this._apiClient);

  Future<Response> getPatientMedicalRecords() async {
    return await _apiClient.get('/api/medical-records/my');
  }

  Future<Response> getMedicalRecordDetails(int id) async {
    return await _apiClient.get('/api/medical-records/$id');
  }

  Future<Response> createMedicalRecord({
    required int appointmentId,
    String? symptoms,
    String? diagnosis,
    String? doctorNotes,
  }) async {
    return await _apiClient.post(
      '/api/medical-records',
      data: {
        'appointment_id': appointmentId,
        'symptoms': symptoms,
        'diagnosis': diagnosis,
        'doctor_notes': doctorNotes,
      },
    );
  }

  Future<Response> addPrescription({
    required int recordId,
    required String medicationName,
    required String dosage,
    required String duration,
    String? instructions,
  }) async {
    return await _apiClient.post(
      '/api/medical-records/$recordId/prescriptions',
      data: {
        'medication_name': medicationName,
        'dosage': dosage,
        'duration': duration,
        'instructions': instructions,
      },
    );
  }
}
