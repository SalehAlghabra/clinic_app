import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';

class WalletApiService {
  final ApiClient _apiClient;

  WalletApiService(this._apiClient);

  Future<Response> getWalletBalance() async {
    return await _apiClient.get('/api/wallet/balance');
  }

  Future<Response> getWalletTransactions({int page = 1}) async {
    return await _apiClient.get('/api/wallet/transactions', queryParameters: {'page': page});
  }
}
