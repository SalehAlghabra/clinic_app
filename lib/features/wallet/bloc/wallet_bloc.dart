import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/wallet_repository.dart';
import 'wallet_event.dart';
import 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final WalletRepository _repository;

  WalletBloc({required WalletRepository repository})
      : _repository = repository,
        super(const WalletInitial()) {
    on<FetchWalletDataEvent>(_onFetchWalletData);
  }

  Future<void> _onFetchWalletData(
    FetchWalletDataEvent event,
    Emitter<WalletState> emit,
  ) async {
    emit(const WalletLoading());
    
    // Fetch both balance and transactions concurrently
    final balanceResult = await _repository.getWalletBalance();
    final transactionsResult = await _repository.getWalletTransactions(page: event.page);

    if (balanceResult.isSuccess) {
      emit(WalletLoadSuccess(
        balance: balanceResult.data!,
        transactions: transactionsResult.data ?? const [],
      ));
    } else {
      final error = balanceResult.failure?.message ?? 'Failed to load wallet balance';
      emit(WalletFailure(error));
    }
  }
}
