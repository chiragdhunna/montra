part of 'budget_bloc.dart';

@freezed
class BudgetEvent with _$BudgetEvent {
  const factory BudgetEvent.started() = _Started;
  const factory BudgetEvent.getBudgetByMonth({required int month}) =
      _GetBudgetByMonth;
  const factory BudgetEvent.deleteBudget({required String budgetId}) =
      _DeleteBudget;
  const factory BudgetEvent.createBudget({
    required int amount,
    required String budgetName,
  }) = _CreateBudget;
  const factory BudgetEvent.updateBudget({
    required int totalBudget,
    required String budgetName,
    required String budgetId,
    required int current,
  }) = _UpdateBudget;
}
