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

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.fcmToken,
    required this.walletBalance,
    required this.violationCount,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      role: json['role'] as String,
      fcmToken: json['fcm_token'] as String?,
      walletBalance: double.tryParse(json['wallet_balance']?.toString() ?? '0.00') ?? 0.00,
      violationCount: json['violation_count'] as int? ?? 0,
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
      ];
}
