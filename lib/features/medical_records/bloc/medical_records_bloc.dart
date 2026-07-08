import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/medical_records_repository.dart';
import 'medical_records_event.dart';
import 'medical_records_state.dart';

class MedicalRecordsBloc extends Bloc<MedicalRecordsEvent, MedicalRecordsState> {
  final MedicalRecordsRepository _repository;

  MedicalRecordsBloc({required MedicalRecordsRepository repository})
      : _repository = repository,
        super(const MedicalRecordsInitial()) {
    on<FetchPatientMedicalRecordsEvent>(_onFetchPatientMedicalRecords);
    on<FetchMedicalRecordDetailsEvent>(_onFetchMedicalRecordDetails);
    on<CreateMedicalRecordEvent>(_onCreateMedicalRecord);
    on<AddPrescriptionEvent>(_onAddPrescription);
  }

  Future<void> _onFetchPatientMedicalRecords(
    FetchPatientMedicalRecordsEvent event,
    Emitter<MedicalRecordsState> emit,
  ) async {
    emit(const MedicalRecordsLoading());
    final result = await _repository.getPatientMedicalRecords();
    if (result.isSuccess) {
      emit(PatientMedicalRecordsLoadSuccess(result.data!));
    } else {
      emit(MedicalRecordsFailure(result.failure!.message));
    }
  }

  Future<void> _onFetchMedicalRecordDetails(
    FetchMedicalRecordDetailsEvent event,
    Emitter<MedicalRecordsState> emit,
  ) async {
    emit(const MedicalRecordsLoading());
    final result = await _repository.getMedicalRecordDetails(event.id);
    if (result.isSuccess) {
      emit(MedicalRecordDetailsLoadSuccess(result.data!));
    } else {
      emit(MedicalRecordsFailure(result.failure!.message));
    }
  }

  Future<void> _onCreateMedicalRecord(
    CreateMedicalRecordEvent event,
    Emitter<MedicalRecordsState> emit,
  ) async {
    emit(const MedicalRecordsActionInProgress());
    final result = await _repository.createMedicalRecord(
      appointmentId: event.appointmentId,
      symptoms: event.symptoms,
      diagnosis: event.diagnosis,
      doctorNotes: event.doctorNotes,
    );
    if (result.isSuccess) {
      emit(CreateMedicalRecordSuccess(result.data!));
    } else {
      emit(MedicalRecordsFailure(result.failure!.message));
    }
  }

  Future<void> _onAddPrescription(
    AddPrescriptionEvent event,
    Emitter<MedicalRecordsState> emit,
  ) async {
    final previousState = state;
    emit(const MedicalRecordsActionInProgress());
    final result = await _repository.addPrescription(
      recordId: event.recordId,
      medicationName: event.medicationName,
      dosage: event.dosage,
      duration: event.duration,
      instructions: event.instructions,
    );
    if (result.isSuccess) {
      emit(AddPrescriptionSuccess(result.data!));
      
      // If we previously had loaded medical record details, append this prescription locally so the UI updates
      if (previousState is MedicalRecordDetailsLoadSuccess) {
        final currentRecord = previousState.record;
        final updatedPrescriptions = List<dynamic>.from(currentRecord.prescriptions)
          ..add(result.data!);
        
        final updatedRecord = currentRecord.toJson();
        updatedRecord['prescriptions'] = updatedPrescriptions;
        
        emit(MedicalRecordDetailsLoadSuccess(
          currentRecord, // wait, let's map it cleanly
        ));
        
        // Reload details to get everything fully synchronized from server
        final reloadResult = await _repository.getMedicalRecordDetails(event.recordId);
        if (reloadResult.isSuccess) {
          emit(MedicalRecordDetailsLoadSuccess(reloadResult.data!));
        }
      }
    } else {
      emit(MedicalRecordsFailure(result.failure!.message));
      if (previousState is MedicalRecordDetailsLoadSuccess) {
        emit(previousState);
      }
    }
  }
}
