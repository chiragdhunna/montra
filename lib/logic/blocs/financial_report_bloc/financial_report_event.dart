part of 'financial_report_bloc.dart';

@freezed
class FinancialReportEvent with _$FinancialReportEvent {
  const factory FinancialReportEvent.loadFinancialReport() =
      _LoadFinancialReport;
  const factory FinancialReportEvent.updateTimeFilter(String filter) =
      _UpdateTimeFilter;
  const factory FinancialReportEvent.updateTransactionType(String type) =
      _UpdateTransactionType;
  const factory FinancialReportEvent.updateCategory(String category) =
      _UpdateCategory;
  const factory FinancialReportEvent.toggleGraphView(bool isGraphSelected) =
      _ToggleGraphView;
}
