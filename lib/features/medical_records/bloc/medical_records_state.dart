import 'package:equatable/equatable.dart';
import '../models/medical_record_model.dart';
import '../models/prescription_model.dart';

abstract class MedicalRecordsState extends Equatable {
  const MedicalRecordsState();

  @override
  List<Object?> get props => [];
}

class MedicalRecordsInitial extends MedicalRecordsState {
  const MedicalRecordsInitial();
}

class MedicalRecordsLoading extends MedicalRecordsState {
  const MedicalRecordsLoading();
}

class PatientMedicalRecordsLoadSuccess extends MedicalRecordsState {
  final List<MedicalRecordModel> records;

  const PatientMedicalRecordsLoadSuccess(this.records);

  @override
  List<Object?> get props => [records];
}

class MedicalRecordDetailsLoadSuccess extends MedicalRecordsState {
  final MedicalRecordModel record;

  const MedicalRecordDetailsLoadSuccess(this.record);

  @override
  List<Object?> get props => [record];
}

class CreateMedicalRecordSuccess extends MedicalRecordsState {
  final MedicalRecordModel record;

  const CreateMedicalRecordSuccess(this.record);

  @override
  List<Object?> get props => [record];
}

class AddPrescriptionSuccess extends MedicalRecordsState {
  final PrescriptionModel prescription;

  const AddPrescriptionSuccess(this.prescription);

  @override
  List<Object?> get props => [prescription];
}

class MedicalRecordsActionInProgress extends MedicalRecordsState {
  const MedicalRecordsActionInProgress();
}

class MedicalRecordsFailure extends MedicalRecordsState {
  final String errorMessage;

  const MedicalRecordsFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
