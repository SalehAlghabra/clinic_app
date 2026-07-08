import 'package:equatable/equatable.dart';

abstract class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object?> get props => [];
}

class FetchWalletDataEvent extends WalletEvent {
  final int page;

  const FetchWalletDataEvent({this.page = 1});

  @override
  List<Object?> get props => [page];
}
