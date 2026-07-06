import 'package:equatable/equatable.dart';

class ServiceModel extends Equatable {
  final int id;
  final int doctorId;
  final String serviceName;
  final double price;

  const ServiceModel({
    required this.id,
    required this.doctorId,
    required this.serviceName,
    required this.price,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] as int,
      doctorId: json['doctor_id'] as int,
      serviceName: json['service_name'] as String,
      price: double.tryParse(json['price']?.toString() ?? '0.00') ?? 0.00,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctor_id': doctorId,
      'service_name': serviceName,
      'price': price,
    };
  }

  @override
  List<Object?> get props => [id, doctorId, serviceName, price];
}
