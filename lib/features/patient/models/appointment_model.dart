import 'package:equatable/equatable.dart';

class AppointmentModel extends Equatable {
  final int id;
  final String doctorName;
  final String specialization;
  final String service;
  final double price;
  final String appointmentDate;
  final String appointmentTime;
  final String status;
  final String? notes;

  const AppointmentModel({
    required this.id,
    required this.doctorName,
    required this.specialization,
    required this.service,
    required this.price,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.status,
    this.notes,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] as int,
      doctorName: json['doctor_name'] as String? ?? '',
      specialization: json['specialization'] as String? ?? '',
      service: json['service'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      appointmentDate: json['appointment_date'] as String? ?? '',
      appointmentTime: json['appointment_time'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctor_name': doctorName,
      'specialization': specialization,
      'service': service,
      'price': price,
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
        specialization,
        service,
        price,
        appointmentDate,
        appointmentTime,
        status,
        notes,
      ];
}
