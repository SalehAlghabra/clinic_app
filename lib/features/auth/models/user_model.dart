import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final String? fcmToken;
  final double walletBalance;
  final int violationCount;
  final String? profilePicture;
  final String? profilePictureUrl;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.fcmToken,
    required this.walletBalance,
    required this.violationCount,
    this.profilePicture,
    this.profilePictureUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      role: json['role'] as String? ?? 'patient',
      fcmToken: json['fcm_token'] as String?,
      walletBalance: double.tryParse(json['wallet_balance']?.toString() ?? '0.00') ?? 0.00,
      violationCount: json['violation_count'] as int? ?? 0,
      profilePicture: json['profile_picture'] as String?,
      profilePictureUrl: json['profile_picture_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'fcm_token': fcmToken,
      'wallet_balance': walletBalance,
      'violation_count': violationCount,
      'profile_picture': profilePicture,
      'profile_picture_url': profilePictureUrl,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        role,
        fcmToken,
        walletBalance,
        violationCount,
        profilePicture,
        profilePictureUrl,
      ];
}
