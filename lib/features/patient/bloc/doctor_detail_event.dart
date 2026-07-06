import 'package:equatable/equatable.dart';

abstract class DoctorDetailEvent extends Equatable {
  const DoctorDetailEvent();

  @override
  List<Object?> get props => [];
}

class FetchDoctorDetailRequested extends DoctorDetailEvent {
  final int doctorId;

  const FetchDoctorDetailRequested(this.doctorId);

  @override
  List<Object?> get props => [doctorId];
}
