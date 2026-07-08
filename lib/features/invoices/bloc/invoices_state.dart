import 'package:equatable/equatable.dart';
import '../models/invoice_model.dart';

abstract class InvoicesState extends Equatable {
  const InvoicesState();

  @override
  List<Object?> get props => [];
}

class InvoicesInitial extends InvoicesState {
  const InvoicesInitial();
}

class InvoicesLoading extends InvoicesState {
  const InvoicesLoading();
}

class InvoicesLoadSuccess extends InvoicesState {
  final List<InvoiceModel> invoices;

  const InvoicesLoadSuccess(this.invoices);

  @override
  List<Object?> get props => [invoices];
}

class InvoicesFailure extends InvoicesState {
  final String errorMessage;

  const InvoicesFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
