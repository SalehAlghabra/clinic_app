import 'package:equatable/equatable.dart';

abstract class MedicalRecordsEvent extends Equatable {
  const MedicalRecordsEvent();

  @override
  List<Object?> get props => [];
}

class FetchPatientMedicalRecordsEvent extends MedicalRecordsEvent {
  const FetchPatientMedicalRecordsEvent();
}

class FetchMedicalRecordDetailsEvent extends MedicalRecordsEvent {
  final int id;

  const FetchMedicalRecordDetailsEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class CreateMedicalRecordEvent extends MedicalRecordsEvent {
  final int appointmentId;
  final String symptoms;
  final String diagnosis;
  final String doctorNotes;

  const CreateMedicalRecordEvent({
    required this.appointmentId,
    required this.symptoms,
    required this.diagnosis,
    required this.doctorNotes,
  });

  @override
  List<Object?> get props => [appointmentId, symptoms, diagnosis, doctorNotes];
}

class AddPrescriptionEvent extends MedicalRecordsEvent {
  final int recordId;
  final String medicationName;
  final String dosage;
  final String duration;
  final String? instructions;

  const AddPrescriptionEvent({
    required this.recordId,
    required this.medicationName,
    required this.dosage,
    required this.duration,
    this.instructions,
  });

  @override
  List<Object?> get props => [recordId, medicationName, dosage, duration, instructions];
}
