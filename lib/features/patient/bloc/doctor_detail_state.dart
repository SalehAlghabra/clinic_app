import 'package:equatable/equatable.dart';
import '../models/doctor_model.dart';
import '../models/schedule_model.dart';

abstract class DoctorDetailState extends Equatable {
  const DoctorDetailState();

  @override
  List<Object?> get props => [];
}

class DoctorDetailInitial extends DoctorDetailState {
  const DoctorDetailInitial();
}

class DoctorDetailLoading extends DoctorDetailState {
  const DoctorDetailLoading();
}

class DoctorDetailSuccess extends DoctorDetailState {
  final DoctorModel doctor;
  final List<ScheduleModel> schedules;

  const DoctorDetailSuccess({
    required this.doctor,
    required this.schedules,
  });

  @override
  List<Object?> get props => [doctor, schedules];
}

class DoctorDetailFailure extends DoctorDetailState {
  final String errorMessage;

  const DoctorDetailFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
