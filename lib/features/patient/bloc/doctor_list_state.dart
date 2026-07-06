import 'package:equatable/equatable.dart';
import '../models/doctor_model.dart';

abstract class DoctorListState extends Equatable {
  const DoctorListState();

  @override
  List<Object?> get props => [];
}

class DoctorListInitial extends DoctorListState {
  const DoctorListInitial();
}

class DoctorListLoading extends DoctorListState {
  const DoctorListLoading();
}

class DoctorListSuccess extends DoctorListState {
  final List<DoctorModel> doctors;

  const DoctorListSuccess(this.doctors);

  @override
  List<Object?> get props => [doctors];
}

class DoctorListFailure extends DoctorListState {
  final String errorMessage;

  const DoctorListFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
