import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/invoices_repository.dart';
import 'invoices_event.dart';
import 'invoices_state.dart';

class InvoicesBloc extends Bloc<InvoicesEvent, InvoicesState> {
  final InvoicesRepository _repository;

  InvoicesBloc({required InvoicesRepository repository})
      : _repository = repository,
        super(const InvoicesInitial()) {
    on<FetchPatientInvoicesEvent>(_onFetchPatientInvoices);
  }

  Future<void> _onFetchPatientInvoices(
    FetchPatientInvoicesEvent event,
    Emitter<InvoicesState> emit,
  ) async {
    emit(const InvoicesLoading());
    final result = await _repository.getPatientInvoices();
    if (result.isSuccess) {
      emit(InvoicesLoadSuccess(result.data!));
    } else {
      emit(InvoicesFailure(result.failure!.message));
    }
  }
}
