import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/patient_repository.dart';
import 'doctor_list_event.dart';
import 'doctor_list_state.dart';

class DoctorListBloc extends Bloc<DoctorListEvent, DoctorListState> {
  final PatientRepository _repository;

  DoctorListBloc({required PatientRepository repository})
      : _repository = repository,
        super(const DoctorListInitial()) {
    on<FetchDoctorsRequested>(_onFetchDoctorsRequested);
  }

  Future<void> _onFetchDoctorsRequested(
    FetchDoctorsRequested event,
    Emitter<DoctorListState> emit,
  ) async {
    emit(const DoctorListLoading());
    final result = await _repository.getDoctors();

    if (result.isSuccess) {
      emit(DoctorListSuccess(result.data!));
    } else {
      emit(DoctorListFailure(result.failure!.message));
    }
  }
}
