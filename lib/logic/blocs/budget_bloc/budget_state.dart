part of 'budget_bloc.dart';

@freezed
class BudgetState with _$BudgetState {
  const factory BudgetState.initial() = _Initial;
  const factory BudgetState.inProgress() = _InProgress;
  const factory BudgetState.failure() = _Failure;
  const factory BudgetState.createBudgetSuccess() = _CreateBudgetSuccess;
  const factory BudgetState.updateBudgetSuccess() = _UpdateBudgetSuccess;
  const factory BudgetState.deleteBudgetSuccess() = _DeleteBudgetSuccess;
  const factory BudgetState.getBudgetByMonthSuccess({
    required BudgetsModel budgets,
  }) = _GetBudgetByMonthSuccess;
  const factory BudgetState.getBudgetsSuccess({required BudgetsModel budgets}) =
      _GetBudgetsSuccess;
}
