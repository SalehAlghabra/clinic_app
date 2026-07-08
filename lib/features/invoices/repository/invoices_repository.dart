import '../../../core/api/api_exceptions.dart';
import '../../../core/errors/failures.dart';
import '../data/invoices_api_service.dart';
import '../models/invoice_model.dart';

class InvoicesResult<T> {
  final T? data;
  final Failure? failure;

  const InvoicesResult.success(T value)
      : data = value,
        failure = null;

  const InvoicesResult.failure(Failure f)
      : data = null,
        failure = f;

  bool get isSuccess => failure == null;
}

class InvoicesRepository {
  final InvoicesApiService _apiService;

  InvoicesRepository(this._apiService);

  Future<InvoicesResult<List<InvoiceModel>>> getPatientInvoices() async {
    try {
      final response = await _apiService.getPatientInvoices();
      final List rawList = response.data as List? ?? [];
      final list = rawList
          .map((e) => InvoiceModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return InvoicesResult.success(list);
    } on ApiException catch (e) {
      return InvoicesResult.failure(ServerFailure(e.message));
    } catch (_) {
      return InvoicesResult.failure(const NetworkFailure());
    }
  }
}
