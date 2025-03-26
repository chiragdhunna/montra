import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:montra/constants/expense_type.dart';

// required: associates our `main.dart` with the code generated by Freezed
part 'expense_model.freezed.dart';
// optional: Since our ExpenseModel class is serializable, we must add this line.
// But if ExpenseModel was not serializable, we could skip it.
part 'expense_model.g.dart';

@freezed
abstract class ExpenseModel with _$ExpenseModel {
  const factory ExpenseModel({
    required String expenseId,
    required int amount,
    required String userId,
    required ExpenseType source,
    String? attachment,
    required String description,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
    required DateTime createdAt,
    String? bankName,
    String? walletName,
  }) = _ExpenseModel;

  factory ExpenseModel.fromJson(Map<String, dynamic> json) =>
      _$ExpenseModelFromJson(json);
}

// Custom converters for DateTime
DateTime _dateTimeFromJson(String date) => DateTime.parse(date);
String _dateTimeToJson(DateTime date) => date.toIso8601String();
