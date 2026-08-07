import 'package:equatable/equatable.dart';

double _toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

class DoctorAppointmentModel extends Equatable {
  final int id;
  final String patientName;
  final String patientPhone;
  final double consultationFee;
  final double additionalCost;
  final String? additionalNote;
  final String appointmentDate;
  final String appointmentTime;
  final String status;
  final String? notes;
  final String? patientProfilePictureUrl;

  const DoctorAppointmentModel({
    required this.id,
    required this.patientName,
    required this.patientPhone,
    required this.consultationFee,
    this.additionalCost = 0.0,
    this.additionalNote,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.status,
    this.notes,
    this.patientProfilePictureUrl,
  });

  factory DoctorAppointmentModel.fromJson(Map<String, dynamic> json) {
    String patName = json['patient_name'] as String? ?? '';
    String patPhone = json['patient_phone'] as String? ?? '';
    String? patPic = json['patient_profile_picture_url'] as String?;

    if (json['patient'] != null) {
      if (patName.isEmpty) patName = json['patient']['name'] as String? ?? '';
      if (patPhone.isEmpty) patPhone = json['patient']['phone'] as String? ?? '';
      patPic ??= json['patient']['profile_picture_url'] as String?;
    }

    return DoctorAppointmentModel(
      id: json['id'] as int,
      patientName: patName.isNotEmpty ? patName : 'Patient',
      patientPhone: patPhone,
      consultationFee: _toDouble(json['consultation_fee'] ?? json['price']),
      additionalCost: _toDouble(json['additional_cost']),
      additionalNote: json['additional_note'] as String?,
      appointmentDate: json['appointment_date'] as String? ?? '',
      appointmentTime: json['appointment_time'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      notes: json['notes'] as String?,
      patientProfilePictureUrl: patPic,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_name': patientName,
      'patient_phone': patientPhone,
      'consultation_fee': consultationFee,
      'additional_cost': additionalCost,
      'additional_note': additionalNote,
      'appointment_date': appointmentDate,
      'appointment_time': appointmentTime,
      'status': status,
      'notes': notes,
    };
  }

  @override
  List<Object?> get props => [
        id,
        patientName,
        patientPhone,
        consultationFee,
        additionalCost,
        additionalNote,
        appointmentDate,
        appointmentTime,
        status,
        notes,
      ];
}
