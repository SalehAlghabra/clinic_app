import 'package:equatable/equatable.dart';
import '../../../core/config/app_config.dart';

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

  static String? _parseProfilePictureUrl(dynamic rawUrl, dynamic rawPath) {
    String? url = rawUrl as String? ?? rawPath as String?;
    if (url == null || url.isEmpty || url.contains('default-avatar.png')) {
      return null;
    }

    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      final base = AppConfig.baseUrl.endsWith('/')
          ? AppConfig.baseUrl.substring(0, AppConfig.baseUrl.length - 1)
          : AppConfig.baseUrl;
      final path = url.startsWith('/') ? url : '/$url';
      return '$base$path';
    }

    if (url.contains('localhost') || url.contains('127.0.0.1')) {
      final baseUri = Uri.parse(AppConfig.baseUrl);
      final rawUri = Uri.parse(url);
      final fixedUri = rawUri.replace(
        scheme: baseUri.scheme,
        host: baseUri.host,
        port: baseUri.hasPort ? baseUri.port : null,
      );
      return fixedUri.toString();
    }

    return url;
  }

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
      profilePictureUrl: _parseProfilePictureUrl(json['profile_picture_url'], json['profile_picture']),
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
