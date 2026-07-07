import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/patient_repository.dart';
import 'doctor_detail_event.dart';
import 'doctor_detail_state.dart';

class DoctorDetailBloc extends Bloc<DoctorDetailEvent, DoctorDetailState> {
  final PatientRepository _repository;

  DoctorDetailBloc({required PatientRepository repository})
      : _repository = repository,
        super(const DoctorDetailInitial()) {
    on<FetchDoctorDetailRequested>(_onFetchDoctorDetailRequested);
  }

  PatientRepository get repository => _repository;

  Future<void> _onFetchDoctorDetailRequested(
    FetchDoctorDetailRequested event,
    Emitter<DoctorDetailState> emit,
  ) async {
    emit(const DoctorDetailLoading());

    // Call detail, schedules, and services in parallel/sequential
    final detailResult = await _repository.getDoctorDetail(event.doctorId);
    final schedulesResult = await _repository.getDoctorSchedules(event.doctorId);
    final servicesResult = await _repository.getDoctorServices(event.doctorId);

    if (detailResult.isSuccess && schedulesResult.isSuccess && servicesResult.isSuccess) {
      emit(DoctorDetailSuccess(
        doctor: detailResult.data!,
        schedules: schedulesResult.data!,
        services: servicesResult.data!,
      ));
    } else {
      final error = detailResult.failure?.message ??
          schedulesResult.failure?.message ??
          servicesResult.failure?.message ??
          'Failed to load doctor details';
      emit(DoctorDetailFailure(error));
    }
  }
}
