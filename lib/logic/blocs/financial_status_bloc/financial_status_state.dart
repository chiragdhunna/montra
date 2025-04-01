part of 'financial_status_bloc.dart';

@freezed
class FinancialStatusState with _$FinancialStatusState {
  const factory FinancialStatusState({
    required FinancialStatus status,
    required Map<String, dynamic>? biggestIncomeSource,
    required Map<String, dynamic>? biggestExpenseSource,
    required int numberOfBudgetsExceeded,
    String? errorMessage,
  }) = _FinancialStatusState;

  factory FinancialStatusState.initial() => FinancialStatusState(
    status: FinancialStatus.initial,
    biggestIncomeSource: null,
    biggestExpenseSource: null,
    numberOfBudgetsExceeded: 0,
    errorMessage: null,
  );
}

enum FinancialStatus { initial, loading, loaded, error }
