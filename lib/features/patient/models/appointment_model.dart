import 'package:equatable/equatable.dart';

double _toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

class AppointmentModel extends Equatable {
  final int id;
  final String doctorName;
  final String patientName;
  final String specialization;
  final double consultationFee;
  final double additionalCost;
  final String? additionalNote;
  final String appointmentDate;
  final String appointmentTime;
  final String status;
  final String? notes;
  final String? doctorPhone;
  final String? patientPhone;
  final String? doctorProfilePictureUrl;
  final bool isPaid;

  const AppointmentModel({
    required this.id,
    required this.doctorName,
    this.patientName = '',
    required this.specialization,
    required this.consultationFee,
    this.additionalCost = 0.0,
    this.additionalNote,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.status,
    this.notes,
    this.doctorPhone,
    this.patientPhone,
    this.doctorProfilePictureUrl,
    this.isPaid = false,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    // Doctor object or user object in nested JSON
    String docName = json['doctor_name'] as String? ?? '';
    String? docPic = json['doctor_profile_picture_url'] as String?;

    if (docName.isEmpty && json['doctor'] != null) {
      if (json['doctor']['user'] != null) {
        docName = json['doctor']['user']['name'] as String? ?? '';
        docPic ??= json['doctor']['user']['profile_picture_url'] as String?;
      } else if (json['doctor']['name'] != null) {
        docName = json['doctor']['name'] as String? ?? '';
      }
    }

    String patName = json['patient_name'] as String? ?? '';
    if (patName.isEmpty && json['patient'] != null) {
      patName = json['patient']['name'] as String? ?? '';
    }

    String spec = json['specialization'] as String? ?? '';
    if (spec.isEmpty && json['doctor'] != null) {
      spec = json['doctor']['specialization'] as String? ?? '';
    }

    return AppointmentModel(
      id: json['id'] as int,
      doctorName: docName.isNotEmpty ? docName : 'Doctor',
      patientName: patName,
      specialization: spec,
      consultationFee: _toDouble(json['consultation_fee'] ?? json['price']),
      additionalCost: _toDouble(json['additional_cost']),
      additionalNote: json['additional_note'] as String?,
      appointmentDate: json['appointment_date'] as String? ?? '',
      appointmentTime: json['appointment_time'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      notes: json['notes'] as String?,
      doctorPhone: json['doctor_phone'] as String?,
      patientPhone: json['patient_phone'] as String?,
      doctorProfilePictureUrl: docPic,
      isPaid: json['is_paid'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctor_name': doctorName,
      'patient_name': patientName,
      'specialization': specialization,
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
        doctorName,
        patientName,
        specialization,
        consultationFee,
        additionalCost,
        additionalNote,
        appointmentDate,
        appointmentTime,
        status,
        notes,
      ];
}
