import '../../../core/api/api_exceptions.dart';
import '../../../core/errors/failures.dart';
import '../data/medical_records_api_service.dart';
import '../models/medical_record_model.dart';
import '../models/prescription_model.dart';

class MedicalRecordResult<T> {
  final T? data;
  final Failure? failure;

  const MedicalRecordResult.success(T value)
      : data = value,
        failure = null;

  const MedicalRecordResult.failure(Failure f)
      : data = null,
        failure = f;

  bool get isSuccess => failure == null;
}

class MedicalRecordsRepository {
  final MedicalRecordsApiService _apiService;

  MedicalRecordsRepository(this._apiService);

  Future<MedicalRecordResult<List<MedicalRecordModel>>> getPatientMedicalRecords() async {
    try {
      final response = await _apiService.getPatientMedicalRecords();
      final List rawList = response.data as List? ?? [];
      final list = rawList
          .map((e) => MedicalRecordModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return MedicalRecordResult.success(list);
    } on ApiException catch (e) {
      return MedicalRecordResult.failure(ServerFailure(e.message));
    } catch (e) {
      return MedicalRecordResult.failure(ServerFailure(e.toString()));
    }
  }

  Future<MedicalRecordResult<MedicalRecordModel>> getMedicalRecordDetails(int id) async {
    try {
      final response = await _apiService.getMedicalRecordDetails(id);
      final record = MedicalRecordModel.fromJson(response.data as Map<String, dynamic>);
      return MedicalRecordResult.success(record);
    } on ApiException catch (e) {
      return MedicalRecordResult.failure(ServerFailure(e.message));
    } catch (e) {
      return MedicalRecordResult.failure(ServerFailure(e.toString()));
    }
  }

  Future<MedicalRecordResult<MedicalRecordModel>> createMedicalRecord({
    required int appointmentId,
    String? symptoms,
    String? diagnosis,
    String? doctorNotes,
  }) async {
    try {
      final response = await _apiService.createMedicalRecord(
        appointmentId: appointmentId,
        symptoms: symptoms,
        diagnosis: diagnosis,
        doctorNotes: doctorNotes,
      );
      final rawRecord = response.data['record'] as Map<String, dynamic>? ?? {};
      // Note: The created record might not contain loaded doctor/patient details immediately,
      // but we parse whatever fields are returned.
      final record = MedicalRecordModel.fromJson(rawRecord);
      return MedicalRecordResult.success(record);
    } on ApiException catch (e) {
      return MedicalRecordResult.failure(ServerFailure(e.message));
    } catch (e) {
      return MedicalRecordResult.failure(ServerFailure(e.toString()));
    }
  }

  Future<MedicalRecordResult<PrescriptionModel>> addPrescription({
    required int recordId,
    required String medicationName,
    required String dosage,
    required String duration,
    String? instructions,
  }) async {
    try {
      final response = await _apiService.addPrescription(
        recordId: recordId,
        medicationName: medicationName,
        dosage: dosage,
        duration: duration,
        instructions: instructions,
      );
      final rawPresc = response.data['prescription'] as Map<String, dynamic>? ?? {};
      final prescription = PrescriptionModel.fromJson(rawPresc);
      return MedicalRecordResult.success(prescription);
    } on ApiException catch (e) {
      return MedicalRecordResult.failure(ServerFailure(e.message));
    } catch (e) {
      return MedicalRecordResult.failure(ServerFailure(e.toString()));
    }
  }
}
