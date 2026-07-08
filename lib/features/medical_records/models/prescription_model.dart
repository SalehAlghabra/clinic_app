import 'package:equatable/equatable.dart';

class PrescriptionModel extends Equatable {
  final int id;
  final int medicalRecordId;
  final String medicationName;
  final String dosage;
  final String duration;
  final String? instructions;

  const PrescriptionModel({
    required this.id,
    required this.medicalRecordId,
    required this.medicationName,
    required this.dosage,
    required this.duration,
    this.instructions,
  });

  factory PrescriptionModel.fromJson(Map<String, dynamic> json) {
    return PrescriptionModel(
      id: json['id'] as int? ?? 0,
      medicalRecordId: json['medical_record_id'] as int? ?? 0,
      medicationName: json['medication_name'] as String? ?? '',
      dosage: json['dosage'] as String? ?? '',
      duration: json['duration'] as String? ?? '',
      instructions: json['instructions'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medical_record_id': medicalRecordId,
      'medication_name': medicationName,
      'dosage': dosage,
      'duration': duration,
      'instructions': instructions,
    };
  }

  @override
  List<Object?> get props => [id, medicalRecordId, medicationName, dosage, duration, instructions];
}
