import 'package:equatable/equatable.dart';
import '../models/wallet_balance_model.dart';
import '../models/wallet_transaction_model.dart';

abstract class WalletState extends Equatable {
  const WalletState();

  @override
  List<Object?> get props => [];
}

class WalletInitial extends WalletState {
  const WalletInitial();
}

class WalletLoading extends WalletState {
  const WalletLoading();
}

class WalletLoadSuccess extends WalletState {
  final WalletBalanceModel balance;
  final List<WalletTransactionModel> transactions;

  const WalletLoadSuccess({
    required this.balance,
    required this.transactions,
  });

  @override
  List<Object?> get props => [balance, transactions];
}

class WalletFailure extends WalletState {
  final String errorMessage;

  const WalletFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
