import '../../../core/api/api_exceptions.dart';
import '../../../core/errors/failures.dart';
import '../data/wallet_api_service.dart';
import '../models/wallet_balance_model.dart';
import '../models/wallet_transaction_model.dart';

class WalletResult<T> {
  final T? data;
  final Failure? failure;

  const WalletResult.success(T value)
      : data = value,
        failure = null;

  const WalletResult.failure(Failure f)
      : data = null,
        failure = f;

  bool get isSuccess => failure == null;
}

class WalletRepository {
  final WalletApiService _apiService;

  WalletRepository(this._apiService);

  Future<WalletResult<WalletBalanceModel>> getWalletBalance() async {
    try {
      final response = await _apiService.getWalletBalance();
      final model = WalletBalanceModel.fromJson(response.data as Map<String, dynamic>);
      return WalletResult.success(model);
    } on ApiException catch (e) {
      return WalletResult.failure(ServerFailure(e.message));
    } catch (_) {
      return WalletResult.failure(const NetworkFailure());
    }
  }

  Future<WalletResult<List<WalletTransactionModel>>> getWalletTransactions({int page = 1}) async {
    try {
      final response = await _apiService.getWalletTransactions(page: page);
      List rawData = [];
      if (response.data is Map<String, dynamic>) {
        final dataField = response.data['data'];
        if (dataField is List) {
          rawData = dataField;
        }
      } else if (response.data is List) {
        rawData = response.data as List;
      }
      final list = rawData
          .whereType<Map<String, dynamic>>()
          .map((e) => WalletTransactionModel.fromJson(e))
          .toList();
      return WalletResult.success(list);
    } on ApiException catch (e) {
      return WalletResult.failure(ServerFailure(e.message));
    } catch (_) {
      return WalletResult.failure(const NetworkFailure());
    }
  }
}
