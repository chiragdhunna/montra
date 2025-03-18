import 'package:freezed_annotation/freezed_annotation.dart';

// required: associates our `main.dart` with the code generated by Freezed
part 'budget_model.freezed.dart';
// optional: Since our BudgetModel class is serializable, we must add this line.
// But if BudgetModel was not serializable, we could skip it.
part 'budget_model.g.dart';

@freezed
abstract class BudgetModel with _$BudgetModel {
  const factory BudgetModel({
    required String name,
    required int totalBudget,
    required String userId,
    required String budgetId,
    required String current,
    required DateTime createdAt,
  }) = _BudgetModel;

  factory BudgetModel.fromJson(Map<String, Object?> json) =>
      _$BudgetModelFromJson(json);
}
