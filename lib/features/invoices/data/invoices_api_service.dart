import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';

class InvoicesApiService {
  final ApiClient _apiClient;

  InvoicesApiService(this._apiClient);

  Future<Response> getPatientInvoices() async {
    return await _apiClient.get('/api/invoices/my');
  }
}
