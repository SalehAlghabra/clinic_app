import 'package:equatable/equatable.dart';
import 'prescription_model.dart';

class MedicalRecordModel extends Equatable {
  final int id;
  final String visitDate;
  final String doctorName;
  final String? patientName;
  final String? symptoms;
  final String? diagnosis;
  final String? doctorNotes;
  final List<PrescriptionModel> prescriptions;

  const MedicalRecordModel({
    required this.id,
    required this.visitDate,
    required this.doctorName,
    this.patientName,
    this.symptoms,
    this.diagnosis,
    this.doctorNotes,
    required this.prescriptions,
  });

  factory MedicalRecordModel.fromJson(Map<String, dynamic> json) {
    var rawPrescriptions = json['prescriptions'] as List? ?? [];
    List<PrescriptionModel> prescriptionList = rawPrescriptions
        .map((p) => PrescriptionModel.fromJson(p as Map<String, dynamic>))
        .toList();

    return MedicalRecordModel(
      id: json['id'] as int? ?? 0,
      visitDate: json['visit_date'] as String? ?? '',
      doctorName: json['doctor_name'] as String? ?? '',
      patientName: json['patient_name'] as String?,
      symptoms: json['symptoms'] as String?,
      diagnosis: json['diagnosis'] as String?,
      doctorNotes: json['doctor_notes'] as String?,
      prescriptions: prescriptionList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'visit_date': visitDate,
      'doctor_name': doctorName,
      'patient_name': patientName,
      'symptoms': symptoms,
      'diagnosis': diagnosis,
      'doctor_notes': doctorNotes,
      'prescriptions': prescriptions.map((p) => p.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        visitDate,
        doctorName,
        patientName,
        symptoms,
        diagnosis,
        doctorNotes,
        prescriptions,
      ];
}
