import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/patient_repository.dart';
import 'appointment_event.dart';
import 'appointment_state.dart';

class AppointmentBloc extends Bloc<AppointmentEvent, AppointmentState> {
  final PatientRepository _patientRepository;

  AppointmentBloc(this._patientRepository) : super(const AppointmentInitial()) {
    on<FetchAppointmentsEvent>(_onFetchAppointments);
    on<FetchAvailableSlotsEvent>(_onFetchAvailableSlots);
    on<PreviewAppointmentEvent>(_onPreviewAppointment);
    on<BookAppointmentEvent>(_onBookAppointment);
    on<CancelAppointmentEvent>(_onCancelAppointment);
  }

  Future<void> _onFetchAppointments(
    FetchAppointmentsEvent event,
    Emitter<AppointmentState> emit,
  ) async {
    emit(const AppointmentLoading());
    final result = await _patientRepository.getPatientAppointments();
    if (result.isSuccess) {
      emit(AppointmentsLoadSuccess(result.data!));
    } else {
      emit(AppointmentFailure(result.failure?.message ?? 'Failed to load appointments'));
    }
  }

  Future<void> _onFetchAvailableSlots(
    FetchAvailableSlotsEvent event,
    Emitter<AppointmentState> emit,
  ) async {
    emit(const AppointmentLoading());
    final result = await _patientRepository.getAvailableSlots(event.doctorId, event.date);
    if (result.isSuccess) {
      emit(AvailableSlotsLoadSuccess(result.data!));
    } else {
      emit(AppointmentFailure(result.failure?.message ?? 'Failed to load available slots'));
    }
  }

  Future<void> _onPreviewAppointment(
    PreviewAppointmentEvent event,
    Emitter<AppointmentState> emit,
  ) async {
    emit(const AppointmentLoading());
    final result = await _patientRepository.previewAppointment(
      doctorId: event.doctorId,
      date: event.date,
      time: event.time,
    );
    if (result.isSuccess) {
      emit(AppointmentPreviewSuccess(result.data!));
    } else {
      emit(AppointmentFailure(result.failure?.message ?? 'Failed to preview appointment'));
    }
  }

  Future<void> _onBookAppointment(
    BookAppointmentEvent event,
    Emitter<AppointmentState> emit,
  ) async {
    emit(const AppointmentActionInProgress());
    final result = await _patientRepository.bookAppointment(
      doctorId: event.doctorId,
      date: event.date,
      time: event.time,
      notes: event.notes,
    );
    if (result.isSuccess) {
      final resData = result.data!;
      emit(AppointmentBookSuccess(
        message: resData['message'] as String? ?? 'Booked successfully',
        depositPaid: (resData['deposit_paid'] as num?)?.toDouble() ?? 0.0,
        walletBalance: (resData['wallet_balance'] as num?)?.toDouble() ?? 0.0,
      ));
    } else {
      emit(AppointmentFailure(result.failure?.message ?? 'Failed to book appointment'));
    }
  }

  Future<void> _onCancelAppointment(
    CancelAppointmentEvent event,
    Emitter<AppointmentState> emit,
  ) async {
    emit(const AppointmentActionInProgress());
    final result = await _patientRepository.cancelAppointment(event.id, reason: event.reason);
    if (result.isSuccess) {
      final resData = result.data!;
      emit(AppointmentCancelSuccess(
        message: resData['message'] as String? ?? 'Cancelled successfully',
        refundStatus: resData['refund_status'] as String? ?? '',
        walletBalance: (resData['wallet_balance'] as num?)?.toDouble() ?? 0.0,
      ));
    } else {
      emit(AppointmentFailure(result.failure?.message ?? 'Failed to cancel appointment'));
    }
  }
}
