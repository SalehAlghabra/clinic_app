import 'package:equatable/equatable.dart';

class WalletTransactionModel extends Equatable {
  final int id;
  final String type;
  final double amount;
  final double balanceBefore;
  final double balanceAfter;
  final String? description;
  final int? appointmentId;
  final String createdAt;
  final String? appointmentDate;
  final String? appointmentTime;

  const WalletTransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.balanceBefore,
    required this.balanceAfter,
    this.description,
    this.appointmentId,
    required this.createdAt,
    this.appointmentDate,
    this.appointmentTime,
  });

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    String? appDate;
    String? appTime;
    final app = json['appointment'] as Map<String, dynamic>?;
    if (app != null) {
      appDate = app['appointment_date'] as String?;
      appTime = app['appointment_time'] as String?;
    }

    return WalletTransactionModel(
      id: json['id'] as int? ?? 0,
      type: json['type'] as String? ?? 'deposit',
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      balanceBefore: double.tryParse(json['balance_before'].toString()) ?? 0.0,
      balanceAfter: double.tryParse(json['balance_after'].toString()) ?? 0.0,
      description: json['description'] as String?,
      appointmentId: json['appointment_id'] as int?,
      createdAt: json['created_at'] as String? ?? '',
      appointmentDate: appDate,
      appointmentTime: appTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'balance_before': balanceBefore,
      'balance_after': balanceAfter,
      'description': description,
      'appointment_id': appointmentId,
      'created_at': createdAt,
      'appointment': appointmentId != null
          ? {
              'id': appointmentId,
              'appointment_date': appointmentDate,
              'appointment_time': appointmentTime,
            }
          : null,
    };
  }

  @override
  List<Object?> get props => [
        id,
        type,
        amount,
        balanceBefore,
        balanceAfter,
        description,
        appointmentId,
        createdAt,
        appointmentDate,
        appointmentTime,
      ];
}
