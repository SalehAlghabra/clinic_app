import '../../../core/api/api_exceptions.dart';
import '../../../core/errors/failures.dart';
import '../data/patient_api_service.dart';
import '../models/doctor_model.dart';
import '../models/schedule_model.dart';
import '../models/appointment_model.dart';
import '../models/appointment_preview_model.dart';

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

  /// Fetch available slots for a doctor on a specific date
  Future<PatientResult<List<String>>> getAvailableSlots(int doctorId, String date) async {
    try {
      final res = await _apiService.getAvailableSlots(doctorId, date);
      final slots = (res['available_slots'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [];
      return PatientResult.success(slots);
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        return const PatientResult.success([]);
      }
      return PatientResult.failure(ServerFailure(e.message));
    } catch (_) {
      return PatientResult.failure(const NetworkFailure());
    }
  }

  /// Preview an appointment booking with wallet calculations
  Future<PatientResult<AppointmentPreviewModel>> previewAppointment({
    required int doctorId,
    required String date,
    required String time,
  }) async {
    try {
      final res = await _apiService.previewAppointment(
        doctorId: doctorId,
        date: date,
        time: time,
      );
      return PatientResult.success(AppointmentPreviewModel.fromJson(res));
    } on ApiException catch (e) {
      return PatientResult.failure(ServerFailure(e.message));
    } catch (e) {
      return PatientResult.failure(ServerFailure(e.toString()));
    }
  }

  /// Book a new appointment
  Future<PatientResult<Map<String, dynamic>>> bookAppointment({
    required int doctorId,
    required String date,
    required String time,
    String? notes,
  }) async {
    try {
      final res = await _apiService.bookAppointment(
        doctorId: doctorId,
        date: date,
        time: time,
        notes: notes,
      );
      return PatientResult.success(res);
    } on ApiException catch (e) {
      return PatientResult.failure(ServerFailure(e.message));
    } catch (e) {
      return PatientResult.failure(ServerFailure(e.toString()));
    }
  }

  /// Fetch patient appointments
  Future<PatientResult<List<AppointmentModel>>> getPatientAppointments() async {
    try {
      final list = await _apiService.getPatientAppointments();
      final appointments = list.map((e) => AppointmentModel.fromJson(e as Map<String, dynamic>)).toList();
      return PatientResult.success(appointments);
    } on ApiException catch (e) {
      return PatientResult.failure(ServerFailure(e.message));
    } catch (_) {
      return PatientResult.failure(const NetworkFailure());
    }
  }

  /// Cancel an appointment
  Future<PatientResult<Map<String, dynamic>>> cancelAppointment(int id, {String? reason}) async {
    try {
      final res = await _apiService.cancelAppointment(id, reason: reason);
      return PatientResult.success(res);
    } on ApiException catch (e) {
      return PatientResult.failure(ServerFailure(e.message));
    } catch (_) {
      return PatientResult.failure(const NetworkFailure());
    }
  }

  /// Pay remaining balance for a completed visit
  Future<PatientResult<Map<String, dynamic>>> payRemainingBalance(int id) async {
    try {
      final res = await _apiService.payRemainingBalance(id);
      return PatientResult.success(res);
    } on ApiException catch (e) {
      return PatientResult.failure(ServerFailure(e.message));
    } catch (_) {
      return PatientResult.failure(const NetworkFailure());
    }
  }
}
