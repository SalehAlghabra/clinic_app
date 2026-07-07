import 'package:equatable/equatable.dart';
import '../models/appointment_model.dart';
import '../models/appointment_preview_model.dart';

abstract class AppointmentState extends Equatable {
  const AppointmentState();

  @override
  List<Object?> get props => [];
}

class AppointmentInitial extends AppointmentState {
  const AppointmentInitial();
}

class AppointmentLoading extends AppointmentState {
  const AppointmentLoading();
}

class AppointmentActionInProgress extends AppointmentState {
  const AppointmentActionInProgress();
}

class AppointmentsLoadSuccess extends AppointmentState {
  final List<AppointmentModel> appointments;

  const AppointmentsLoadSuccess(this.appointments);

  @override
  List<Object?> get props => [appointments];
}

class AvailableSlotsLoadSuccess extends AppointmentState {
  final List<String> slots;

  const AvailableSlotsLoadSuccess(this.slots);

  @override
  List<Object?> get props => [slots];
}

class AppointmentPreviewSuccess extends AppointmentState {
  final AppointmentPreviewModel preview;

  const AppointmentPreviewSuccess(this.preview);

  @override
  List<Object?> get props => [preview];
}

class AppointmentBookSuccess extends AppointmentState {
  final String message;
  final double depositPaid;
  final double walletBalance;

  const AppointmentBookSuccess({
    required this.message,
    required this.depositPaid,
    required this.walletBalance,
  });

  @override
  List<Object?> get props => [message, depositPaid, walletBalance];
}

class AppointmentCancelSuccess extends AppointmentState {
  final String message;
  final String refundStatus;
  final double walletBalance;

  const AppointmentCancelSuccess({
    required this.message,
    required this.refundStatus,
    required this.walletBalance,
  });

  @override
  List<Object?> get props => [message, refundStatus, walletBalance];
}

class AppointmentFailure extends AppointmentState {
  final String errorMessage;

  const AppointmentFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
