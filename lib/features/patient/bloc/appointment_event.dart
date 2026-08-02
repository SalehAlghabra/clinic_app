import 'package:equatable/equatable.dart';

abstract class AppointmentEvent extends Equatable {
  const AppointmentEvent();

  @override
  List<Object?> get props => [];
}

class FetchAppointmentsEvent extends AppointmentEvent {
  const FetchAppointmentsEvent();
}

class FetchAvailableSlotsEvent extends AppointmentEvent {
  final int doctorId;
  final String date;

  const FetchAvailableSlotsEvent({
    required this.doctorId,
    required this.date,
  });

  @override
  List<Object?> get props => [doctorId, date];
}

class PreviewAppointmentEvent extends AppointmentEvent {
  final int doctorId;
  final String date;
  final String time;

  const PreviewAppointmentEvent({
    required this.doctorId,
    required this.date,
    required this.time,
  });

  @override
  List<Object?> get props => [doctorId, date, time];
}

class BookAppointmentEvent extends AppointmentEvent {
  final int doctorId;
  final String date;
  final String time;
  final String? notes;

  const BookAppointmentEvent({
    required this.doctorId,
    required this.date,
    required this.time,
    this.notes,
  });

  @override
  List<Object?> get props => [doctorId, date, time, notes];
}

class CancelAppointmentEvent extends AppointmentEvent {
  final int id;
  final String? reason;

  const CancelAppointmentEvent({
    required this.id,
    this.reason,
  });

  @override
  List<Object?> get props => [id, reason];
}
