part of 'financial_report_bloc.dart';

@freezed
class FinancialReportState with _$FinancialReportState {
  const factory FinancialReportState.initial() = _Initial;
  const factory FinancialReportState.loading() = _Loading;
  const factory FinancialReportState.loaded({
    required int totalIncome,
    required int totalExpense,
    required int totalBalance,
    required List<Map<String, dynamic>> incomeBreakdown,
    required List<Map<String, dynamic>> expenseBreakdown,
    required Map<String, dynamic> financeStats,
  }) = _Loaded;
  const factory FinancialReportState.failure(String error) = _Failure;
}
