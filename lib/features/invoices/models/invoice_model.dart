import 'package:equatable/equatable.dart';

class InvoiceModel extends Equatable {
  final int id;
  final String doctorName;
  final String service;
  final String visitDate;
  final double totalAmount;
  final double depositAmount;
  final double remainingAmount;
  final String paymentStatus;
  final String? paymentMethod;
  final String? issuedAt;

  const InvoiceModel({
    required this.id,
    required this.doctorName,
    required this.service,
    required this.visitDate,
    required this.totalAmount,
    required this.depositAmount,
    required this.remainingAmount,
    required this.paymentStatus,
    this.paymentMethod,
    this.issuedAt,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['id'] as int? ?? 0,
      doctorName: json['doctor_name'] as String? ?? '',
      service: json['service'] as String? ?? '',
      visitDate: json['visit_date'] as String? ?? '',
      totalAmount: double.tryParse(json['total_amount'].toString()) ?? 0.0,
      depositAmount: double.tryParse(json['deposit_amount'].toString()) ?? 0.0,
      remainingAmount: double.tryParse(json['remaining_amount'].toString()) ?? 0.0,
      paymentStatus: json['payment_status'] as String? ?? 'unpaid',
      paymentMethod: json['payment_method'] as String?,
      issuedAt: json['issued_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctor_name': doctorName,
      'service': service,
      'visit_date': visitDate,
      'total_amount': totalAmount,
      'deposit_amount': depositAmount,
      'remaining_amount': remainingAmount,
      'payment_status': paymentStatus,
      'payment_method': paymentMethod,
      'issued_at': issuedAt,
    };
  }

  @override
  List<Object?> get props => [
        id,
        doctorName,
        service,
        visitDate,
        totalAmount,
        depositAmount,
        remainingAmount,
        paymentStatus,
        paymentMethod,
        issuedAt,
      ];
}
