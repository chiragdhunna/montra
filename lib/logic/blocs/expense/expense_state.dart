part of 'expense_bloc.dart';

@freezed
class ExpenseState with _$ExpenseState {
  const factory ExpenseState.initial() = _Initial;
  const factory ExpenseState.getExpenseSuccess({
    required int expense,
    required ExpenseStatsModel expenseStats,
  }) = _GetExpenseSuccess;
  const factory ExpenseState.setExpenseSuccess() = _SetExpenseSuccess;
  const factory ExpenseState.failure() = _Failure;
  const factory ExpenseState.inProgress() = _InProgress;
}
