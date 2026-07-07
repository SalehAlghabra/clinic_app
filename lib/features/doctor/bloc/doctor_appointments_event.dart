import 'package:equatable/equatable.dart';

abstract class DoctorAppointmentsEvent extends Equatable {
  const DoctorAppointmentsEvent();

  @override
  List<Object?> get props => [];
}

class FetchDoctorAppointmentsEvent extends DoctorAppointmentsEvent {
  const FetchDoctorAppointmentsEvent();
}

class UpdateAppointmentStatusEvent extends DoctorAppointmentsEvent {
  final int id;
  final String status;

  const UpdateAppointmentStatusEvent({required this.id, required this.status});

  @override
  List<Object?> get props => [id, status];
}

class CancelDayAppointmentsEvent extends DoctorAppointmentsEvent {
  final String date;
  final String? reason;

  const CancelDayAppointmentsEvent({required this.date, this.reason});

  @override
  List<Object?> get props => [date, reason];
}
