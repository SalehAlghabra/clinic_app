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
  final double? additionalCost;
  final String? additionalNote;

  const UpdateAppointmentStatusEvent({
    required this.id,
    required this.status,
    this.additionalCost,
    this.additionalNote,
  });

  @override
  List<Object?> get props => [id, status, additionalCost, additionalNote];
}

class CancelDayAppointmentsEvent extends DoctorAppointmentsEvent {
  final String date;
  final String? reason;

  const CancelDayAppointmentsEvent({required this.date, this.reason});

  @override
  List<Object?> get props => [date, reason];
}
