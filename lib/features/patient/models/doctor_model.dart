import 'package:equatable/equatable.dart';

double _toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

class DoctorModel extends Equatable {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String specialization;
  final String? bio;
  final double consultationFee;
  final String? profilePictureUrl;

  const DoctorModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.specialization,
    this.bio,
    this.consultationFee = 0.0,
    this.profilePictureUrl,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Doctor',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      specialization: json['specialization'] as String? ?? '',
      bio: json['bio'] as String?,
      consultationFee: _toDouble(json['consultation_fee']),
      profilePictureUrl: json['profile_picture_url'] as String?,
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
      'consultation_fee': consultationFee,
      'profile_picture_url': profilePictureUrl,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        specialization,
        bio,
        consultationFee,
        profilePictureUrl,
      ];
}
