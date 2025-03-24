import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:montra/logic/api/expense/models/expense_stats_frequency_model.dart';
import 'package:montra/logic/api/expense/models/expense_stats_summary_model.dart';

// required: associates our `main.dart` with the code generated by Freezed
part 'expense_stats_model.freezed.dart';
// optional: Since our ExpenseStatsModel class is serializable, we must add this line.
// But if ExpenseStatsModel was not serializable, we could skip it.
part 'expense_stats_model.g.dart';

@freezed
abstract class ExpenseStatsModel with _$ExpenseStatsModel {
  const factory ExpenseStatsModel({
    required ExpenseStatsSummaryModel summary,
    required ExpenseStatsFrequencyModel frequency,
  }) = _ExpenseStatsModel;

  factory ExpenseStatsModel.fromJson(Map<String, Object?> json) =>
      _$ExpenseStatsModelFromJson(json);
}
