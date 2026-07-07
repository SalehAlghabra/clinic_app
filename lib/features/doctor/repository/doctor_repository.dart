import '../../../core/api/api_exceptions.dart';
import '../../../core/errors/failures.dart';
import '../data/doctor_api_service.dart';
import '../models/doctor_appointment_model.dart';

class DoctorResult<T> {
  final T? data;
  final Failure? failure;

  const DoctorResult.success(T value)
      : data = value,
        failure = null;

  const DoctorResult.failure(Failure f)
      : data = null,
        failure = f;

  bool get isSuccess => failure == null;
}

class DoctorRepository {
  final DoctorApiService _apiService;

  DoctorRepository(this._apiService);

  /// Fetch list of doctor appointments
  Future<DoctorResult<List<DoctorAppointmentModel>>> getDoctorAppointments() async {
    try {
      final list = await _apiService.getDoctorAppointments();
      final appointments = list
          .map((e) => DoctorAppointmentModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return DoctorResult.success(appointments);
    } on ApiException catch (e) {
      return DoctorResult.failure(ServerFailure(e.message));
    } catch (_) {
      return DoctorResult.failure(const NetworkFailure());
    }
  }

  /// Update appointment status
  Future<DoctorResult<String>> updateAppointmentStatus(int id, String status) async {
    try {
      final data = await _apiService.updateAppointmentStatus(id, status);
      final msg = data['message'] as String? ?? 'Status updated successfully';
      return DoctorResult.success(msg);
    } on ApiException catch (e) {
      return DoctorResult.failure(ServerFailure(e.message));
    } catch (_) {
      return DoctorResult.failure(const NetworkFailure());
    }
  }

  /// Cancel all appointments for a specific day
  Future<DoctorResult<String>> cancelDayAppointments({
    required String date,
    String? reason,
  }) async {
    try {
      final data = await _apiService.cancelDayAppointments(date: date, reason: reason);
      final msg = data['message'] as String? ?? 'Appointments cancelled successfully';
      final refundedCount = data['refunded_count'] as int? ?? 0;
      return DoctorResult.success('$msg ($refundedCount visits refunded)');
    } on ApiException catch (e) {
      return DoctorResult.failure(ServerFailure(e.message));
    } catch (_) {
      return DoctorResult.failure(const NetworkFailure());
    }
  }
}
