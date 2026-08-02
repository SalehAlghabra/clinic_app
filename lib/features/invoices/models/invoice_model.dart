import 'package:equatable/equatable.dart';

double _toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

class InvoiceModel extends Equatable {
  final int id;
  final String doctorName;
  final String patientName;
  final String visitDate;
  final double consultationFee;
  final double totalAmount;
  final double depositAmount;
  final double remainingAmount;
  final String paymentStatus;
  final String? paymentMethod;
  final String? issuedAt;

  const InvoiceModel({
    required this.id,
    required this.doctorName,
    this.patientName = '',
    required this.visitDate,
    required this.consultationFee,
    required this.totalAmount,
    required this.depositAmount,
    required this.remainingAmount,
    required this.paymentStatus,
    this.paymentMethod,
    this.issuedAt,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    String docName = json['doctor_name'] as String? ?? '';
    String patName = json['patient_name'] as String? ?? '';
    String vDate = json['visit_date'] as String? ?? json['issued_at'] as String? ?? '';

    if (json['appointment'] != null) {
      final appt = json['appointment'];
      if (docName.isEmpty && appt['doctor'] != null && appt['doctor']['user'] != null) {
        docName = appt['doctor']['user']['name'] as String? ?? '';
      }
      if (patName.isEmpty && appt['patient'] != null) {
        patName = appt['patient']['name'] as String? ?? '';
      }
      if (vDate.isEmpty && appt['appointment_date'] != null) {
        vDate = appt['appointment_date'] as String? ?? '';
      }
    }

    return InvoiceModel(
      id: json['id'] as int? ?? 0,
      doctorName: docName.isNotEmpty ? docName : 'Doctor',
      patientName: patName,
      visitDate: vDate,
      consultationFee: _toDouble(json['consultation_fee'] ?? json['deposit_amount']),
      totalAmount: _toDouble(json['total_amount']),
      depositAmount: _toDouble(json['deposit_amount']),
      remainingAmount: _toDouble(json['remaining_amount']),
      paymentStatus: json['payment_status'] as String? ?? 'unpaid',
      paymentMethod: json['payment_method'] as String?,
      issuedAt: json['issued_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctor_name': doctorName,
      'patient_name': patientName,
      'visit_date': visitDate,
      'consultation_fee': consultationFee,
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
        patientName,
        visitDate,
        consultationFee,
        totalAmount,
        depositAmount,
        remainingAmount,
        paymentStatus,
        paymentMethod,
        issuedAt,
      ];
}
