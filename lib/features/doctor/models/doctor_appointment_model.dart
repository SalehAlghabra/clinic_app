import 'package:equatable/equatable.dart';

class DoctorAppointmentModel extends Equatable {
  final int id;
  final String patientName;
  final String patientPhone;
  final String service;
  final String appointmentDate;
  final String appointmentTime;
  final String status;
  final String? notes;

  const DoctorAppointmentModel({
    required this.id,
    required this.patientName,
    required this.patientPhone,
    required this.service,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.status,
    this.notes,
  });

  factory DoctorAppointmentModel.fromJson(Map<String, dynamic> json) {
    return DoctorAppointmentModel(
      id: json['id'] as int,
      patientName: json['patient_name'] as String? ?? '',
      patientPhone: json['patient_phone'] as String? ?? '',
      service: json['service'] as String? ?? '',
      appointmentDate: json['appointment_date'] as String? ?? '',
      appointmentTime: json['appointment_time'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_name': patientName,
      'patient_phone': patientPhone,
      'service': service,
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
        service,
        appointmentDate,
        appointmentTime,
        status,
        notes,
      ];
}
