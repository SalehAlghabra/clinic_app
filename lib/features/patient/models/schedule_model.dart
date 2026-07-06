import 'package:equatable/equatable.dart';

class ScheduleModel extends Equatable {
  final int id;
  final int doctorId;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final int durationPerPatient;

  const ScheduleModel({
    required this.id,
    required this.doctorId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.durationPerPatient,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['id'] as int,
      doctorId: json['doctor_id'] as int,
      dayOfWeek: json['day_of_week'] as String,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      durationPerPatient: json['duration_per_patient'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctor_id': doctorId,
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
      'duration_per_patient': durationPerPatient,
    };
  }

  @override
  List<Object?> get props => [
        id,
        doctorId,
        dayOfWeek,
        startTime,
        endTime,
        durationPerPatient,
      ];
}
