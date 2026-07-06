import 'package:equatable/equatable.dart';

abstract class DoctorListEvent extends Equatable {
  const DoctorListEvent();

  @override
  List<Object?> get props => [];
}

class FetchDoctorsRequested extends DoctorListEvent {
  const FetchDoctorsRequested();
}
