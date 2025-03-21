import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:montra/logic/api/expense/models/expense_type_model.dart';

// required: associates our `main.dart` with the code generated by Freezed
part 'income_model.freezed.dart';
// optional: Since our IncomeModel class is serializable, we must add this line.
// But if IncomeModel was not serializable, we could skip it.
part 'income_model.g.dart';

@freezed
abstract class IncomeModel with _$IncomeModel {
  const factory IncomeModel({
    required String name,
    required String userId,
    required String incomeId,
    required int amount,
    required ExpenseType source,
    String? attachment,
    String? description,
    required DateTime createdAt,
  }) = _IncomeModel;

  factory IncomeModel.fromJson(Map<String, Object?> json) =>
      _$IncomeModelFromJson(json);
}
