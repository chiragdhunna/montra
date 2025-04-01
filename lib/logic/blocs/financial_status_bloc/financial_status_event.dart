part of 'financial_status_bloc.dart';

@freezed
class FinancialStatusEvent with _$FinancialStatusEvent {
  const factory FinancialStatusEvent.loadFinancialStatus() =
      LoadFinancialStatus;
}
