part of 'expense_bloc.dart';

@freezed
class ExpenseEvent with _$ExpenseEvent {
  const factory ExpenseEvent.started() = _Started;
  const factory ExpenseEvent.getExpense() = _GetExpense;
  const factory ExpenseEvent.setExpense({
    required int amount,
    required IncomeSource source,
    required String description,
  }) = _SetExpense;
}
