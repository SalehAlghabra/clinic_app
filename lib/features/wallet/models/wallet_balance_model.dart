import 'package:equatable/equatable.dart';

class WalletBalanceModel extends Equatable {
  final double walletBalance;
  final int violationCount;
  final double depositAmount;

  const WalletBalanceModel({
    required this.walletBalance,
    required this.violationCount,
    required this.depositAmount,
  });

  factory WalletBalanceModel.fromJson(Map<String, dynamic> json) {
    return WalletBalanceModel(
      walletBalance: double.tryParse(json['wallet_balance'].toString()) ?? 0.0,
      violationCount: json['violation_count'] as int? ?? 0,
      depositAmount: double.tryParse(json['deposit_amount'].toString()) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wallet_balance': walletBalance,
      'violation_count': violationCount,
      'deposit_amount': depositAmount,
    };
  }

  @override
  List<Object?> get props => [walletBalance, violationCount, depositAmount];
}
