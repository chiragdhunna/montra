import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:montra/logic/api/income/models/income_model.dart';

// required: associates our `main.dart` with the code generated by Freezed
part 'incomes_model.freezed.dart';
// optional: Since our IncomesModel class is serializable, we must add this line.
// But if IncomesModel was not serializable, we could skip it.
part 'incomes_model.g.dart';

@freezed
abstract class IncomesModel with _$IncomesModel {
  const factory IncomesModel({required List<IncomeModel> incomes}) =
      _IncomesModel;

  factory IncomesModel.fromJson(Map<String, Object?> json) =>
      _$IncomesModelFromJson(json);
}
