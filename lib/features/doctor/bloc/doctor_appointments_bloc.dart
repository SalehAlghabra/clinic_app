import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/doctor_repository.dart';
import 'doctor_appointments_event.dart';
import 'doctor_appointments_state.dart';

class DoctorAppointmentsBloc extends Bloc<DoctorAppointmentsEvent, DoctorAppointmentsState> {
  final DoctorRepository _repository;

  DoctorAppointmentsBloc({required DoctorRepository repository})
      : _repository = repository,
        super(const DoctorAppointmentsInitial()) {
    on<FetchDoctorAppointmentsEvent>(_onFetchDoctorAppointments);
    on<UpdateAppointmentStatusEvent>(_onUpdateAppointmentStatus);
    on<CancelDayAppointmentsEvent>(_onCancelDayAppointments);
  }

  Future<void> _onFetchDoctorAppointments(
    FetchDoctorAppointmentsEvent event,
    Emitter<DoctorAppointmentsState> emit,
  ) async {
    emit(const DoctorAppointmentsLoading());
    final result = await _repository.getDoctorAppointments();
    if (result.isSuccess) {
      emit(DoctorAppointmentsLoadSuccess(result.data!));
    } else {
      emit(DoctorAppointmentsFailure(result.failure!.message));
    }
  }

  Future<void> _onUpdateAppointmentStatus(
    UpdateAppointmentStatusEvent event,
    Emitter<DoctorAppointmentsState> emit,
  ) async {
    final previousState = state;
    emit(const DoctorAppointmentActionInProgress());
    final result = await _repository.updateAppointmentStatus(
      event.id,
      event.status,
      additionalCost: event.additionalCost,
      additionalNote: event.additionalNote,
    );
    if (result.isSuccess) {
      emit(DoctorAppointmentActionSuccess(result.data!));
      // Reload appointments list
      final loadResult = await _repository.getDoctorAppointments();
      if (loadResult.isSuccess) {
        emit(DoctorAppointmentsLoadSuccess(loadResult.data!));
      } else {
        emit(DoctorAppointmentsLoadSuccess(
          previousState is DoctorAppointmentsLoadSuccess ? previousState.appointments : const [],
        ));
      }
    } else {
      emit(DoctorAppointmentsFailure(result.failure!.message));
      if (previousState is DoctorAppointmentsLoadSuccess) {
        emit(previousState);
      }
    }
  }

  Future<void> _onCancelDayAppointments(
    CancelDayAppointmentsEvent event,
    Emitter<DoctorAppointmentsState> emit,
  ) async {
    final previousState = state;
    emit(const DoctorAppointmentActionInProgress());
    final result = await _repository.cancelDayAppointments(
      date: event.date,
      reason: event.reason,
    );
    if (result.isSuccess) {
      emit(DoctorAppointmentActionSuccess(result.data!));
      // Reload appointments list
      final loadResult = await _repository.getDoctorAppointments();
      if (loadResult.isSuccess) {
        emit(DoctorAppointmentsLoadSuccess(loadResult.data!));
      } else {
        emit(DoctorAppointmentsLoadSuccess(
          previousState is DoctorAppointmentsLoadSuccess ? previousState.appointments : const [],
        ));
      }
    } else {
      emit(DoctorAppointmentsFailure(result.failure!.message));
      if (previousState is DoctorAppointmentsLoadSuccess) {
        emit(previousState);
      }
    }
  }
}
