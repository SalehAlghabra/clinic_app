import 'package:equatable/equatable.dart';

class DoctorModel extends Equatable {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String specialization;
  final String? bio;

  const DoctorModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.specialization,
    this.bio,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      specialization: json['specialization'] as String,
      bio: json['bio'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'specialization': specialization,
      'bio': bio,
    };
  }

  @override
  List<Object?> get props => [id, name, email, phone, specialization, bio];
}
