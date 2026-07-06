import '../../../core/api/api_exceptions.dart';
import '../../../core/errors/failures.dart';
import '../data/patient_api_service.dart';
import '../models/doctor_model.dart';
import '../models/schedule_model.dart';
import '../models/service_model.dart';

class PatientResult<T> {
  final T? data;
  final Failure? failure;

  const PatientResult.success(T value)
      : data = value,
        failure = null;

  const PatientResult.failure(Failure f)
      : data = null,
        failure = f;

  bool get isSuccess => failure == null;
}

class PatientRepository {
  final PatientApiService _apiService;

  PatientRepository(this._apiService);

  /// Fetch list of all doctors
  Future<PatientResult<List<DoctorModel>>> getDoctors() async {
    try {
      final list = await _apiService.getDoctors();
      final doctors = list.map((e) => DoctorModel.fromJson(e as Map<String, dynamic>)).toList();
      return PatientResult.success(doctors);
    } on ApiException catch (e) {
      return PatientResult.failure(ServerFailure(e.message));
    } catch (_) {
      return PatientResult.failure(const NetworkFailure());
    }
  }

  /// Fetch details of a single doctor
  Future<PatientResult<DoctorModel>> getDoctorDetail(int id) async {
    try {
      final data = await _apiService.getDoctorDetail(id);
      final doctor = DoctorModel.fromJson(data);
      return PatientResult.success(doctor);
    } on ApiException catch (e) {
      return PatientResult.failure(ServerFailure(e.message));
    } catch (_) {
      return PatientResult.failure(const NetworkFailure());
    }
  }

  /// Fetch schedule lists for a doctor
  Future<PatientResult<List<ScheduleModel>>> getDoctorSchedules(int doctorId) async {
    try {
      final list = await _apiService.getDoctorSchedules(doctorId);
      final schedules = list.map((e) => ScheduleModel.fromJson(e as Map<String, dynamic>)).toList();
      return PatientResult.success(schedules);
    } on ApiException catch (e) {
      return PatientResult.failure(ServerFailure(e.message));
    } catch (_) {
      return PatientResult.failure(const NetworkFailure());
    }
  }

  /// Fetch services for a doctor
  Future<PatientResult<List<ServiceModel>>> getDoctorServices(int doctorId) async {
    try {
      final list = await _apiService.getDoctorServices(doctorId);
      final services = list.map((e) => ServiceModel.fromJson(e as Map<String, dynamic>)).toList();
      return PatientResult.success(services);
    } on ApiException catch (e) {
      return PatientResult.failure(ServerFailure(e.message));
    } catch (_) {
      return PatientResult.failure(const NetworkFailure());
    }
  }
}
