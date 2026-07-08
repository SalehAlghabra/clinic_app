import 'package:equatable/equatable.dart';

abstract class InvoicesEvent extends Equatable {
  const InvoicesEvent();

  @override
  List<Object?> get props => [];
}

class FetchPatientInvoicesEvent extends InvoicesEvent {
  const FetchPatientInvoicesEvent();
}
