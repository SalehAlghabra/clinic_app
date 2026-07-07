import 'package:equatable/equatable.dart';
import '../models/doctor_appointment_model.dart';

abstract class DoctorAppointmentsState extends Equatable {
  const DoctorAppointmentsState();

  @override
  List<Object?> get props => [];
}

class DoctorAppointmentsInitial extends DoctorAppointmentsState {
  const DoctorAppointmentsInitial();
}

class DoctorAppointmentsLoading extends DoctorAppointmentsState {
  const DoctorAppointmentsLoading();
}

class DoctorAppointmentsLoadSuccess extends DoctorAppointmentsState {
  final List<DoctorAppointmentModel> appointments;

  const DoctorAppointmentsLoadSuccess(this.appointments);

  @override
  List<Object?> get props => [appointments];
}

class DoctorAppointmentActionInProgress extends DoctorAppointmentsState {
  const DoctorAppointmentActionInProgress();
}

class DoctorAppointmentActionSuccess extends DoctorAppointmentsState {
  final String message;

  const DoctorAppointmentActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class DoctorAppointmentsFailure extends DoctorAppointmentsState {
  final String errorMessage;

  const DoctorAppointmentsFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
