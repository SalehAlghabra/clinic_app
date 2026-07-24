import 'package:equatable/equatable.dart';

double _parseDouble(dynamic val) {
  if (val == null) return 0.0;
  if (val is num) return val.toDouble();
  if (val is String) return double.tryParse(val) ?? 0.0;
  return 0.0;
}

double? _parseNullableDouble(dynamic val) {
  if (val == null) return null;
  if (val is num) return val.toDouble();
  if (val is String) return double.tryParse(val);
  return null;
}

class AppointmentPreviewModel extends Equatable {
  final BookingSummary bookingSummary;
  final PaymentSummary paymentSummary;
  final String message;

  const AppointmentPreviewModel({
    required this.bookingSummary,
    required this.paymentSummary,
    required this.message,
  });

  factory AppointmentPreviewModel.fromJson(Map<String, dynamic> json) {
    return AppointmentPreviewModel(
      bookingSummary: BookingSummary.fromJson(json['booking_summary'] as Map<String, dynamic>? ?? {}),
      paymentSummary: PaymentSummary.fromJson(json['payment_summary'] as Map<String, dynamic>? ?? {}),
      message: json['message'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [bookingSummary, paymentSummary, message];
}

class BookingSummary extends Equatable {
  final String serviceName;
  final double servicePrice;
  final String appointmentDate;
  final String appointmentTime;

  const BookingSummary({
    required this.serviceName,
    required this.servicePrice,
    required this.appointmentDate,
    required this.appointmentTime,
  });

  factory BookingSummary.fromJson(Map<String, dynamic> json) {
    return BookingSummary(
      serviceName: json['service_name'] as String? ?? '',
      servicePrice: _parseDouble(json['service_price']),
      appointmentDate: json['appointment_date'] as String? ?? '',
      appointmentTime: json['appointment_time'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [serviceName, servicePrice, appointmentDate, appointmentTime];
}

class PaymentSummary extends Equatable {
  final double depositRequired;
  final double walletBalance;
  final double? balanceAfter;
  final double remainingAtVisit;
  final bool hasSufficient;

  const PaymentSummary({
    required this.depositRequired,
    required this.walletBalance,
    this.balanceAfter,
    required this.remainingAtVisit,
    required this.hasSufficient,
  });

  factory PaymentSummary.fromJson(Map<String, dynamic> json) {
    return PaymentSummary(
      depositRequired: _parseDouble(json['deposit_required']),
      walletBalance: _parseDouble(json['wallet_balance']),
      balanceAfter: _parseNullableDouble(json['balance_after']),
      remainingAtVisit: _parseDouble(json['remaining_at_visit']),
      hasSufficient: json['has_sufficient'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
        depositRequired,
        walletBalance,
        balanceAfter,
        remainingAtVisit,
        hasSufficient,
      ];
}
